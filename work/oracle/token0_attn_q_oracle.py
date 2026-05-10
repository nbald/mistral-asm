#!/usr/bin/env python3
"""External oracle for the token-0 first attention query projection smoke.

This file is verification tooling, not runtime source. It parses the target
GGUF directly, reproduces the scalar f32 arithmetic order used by the assembly
smoke path, and prints the first four f32 output words as raw bits.
"""

import argparse
import mmap
import os
import struct

import numpy as np


GGUF_TYPE_UINT8 = 0
GGUF_TYPE_INT8 = 1
GGUF_TYPE_UINT16 = 2
GGUF_TYPE_INT16 = 3
GGUF_TYPE_UINT32 = 4
GGUF_TYPE_INT32 = 5
GGUF_TYPE_FLOAT32 = 6
GGUF_TYPE_BOOL = 7
GGUF_TYPE_STRING = 8
GGUF_TYPE_ARRAY = 9
GGUF_TYPE_UINT64 = 10
GGUF_TYPE_INT64 = 11
GGUF_TYPE_FLOAT64 = 12

GGML_TYPE_F32 = 0
GGML_TYPE_Q8_0 = 8

Q8_0_BLOCK_VALUES = 32
Q8_0_BLOCK_BYTES = 34

EPSILON_KEY = "mistral3.attention.layer_norm_rms_epsilon"
TOKEN_EMBD = "token_embd.weight"
ATTN_NORM = "blk.0.attn_norm.weight"
ATTN_Q = "blk.0.attn_q.weight"

SCALAR_TYPE_BYTES = {
    GGUF_TYPE_UINT8: 1,
    GGUF_TYPE_INT8: 1,
    GGUF_TYPE_UINT16: 2,
    GGUF_TYPE_INT16: 2,
    GGUF_TYPE_UINT32: 4,
    GGUF_TYPE_INT32: 4,
    GGUF_TYPE_FLOAT32: 4,
    GGUF_TYPE_BOOL: 1,
    GGUF_TYPE_UINT64: 8,
    GGUF_TYPE_INT64: 8,
    GGUF_TYPE_FLOAT64: 8,
}


def require(condition, message):
    if not condition:
        raise SystemExit(f"oracle: {message}")


def require_span(buf, offset, size):
    require(offset >= 0 and size >= 0 and offset + size <= len(buf),
            f"out-of-bounds read at {offset} size {size}")


def align_up(value, alignment):
    return (value + alignment - 1) & -alignment


def f32(value):
    return np.float32(value)


def f32_bits(value):
    return struct.unpack("<I", struct.pack("<f", float(f32(value))))[0]


def f32_from_bits(bits):
    return f32(struct.unpack("<f", struct.pack("<I", bits))[0])


def read_u32(buf, offset):
    require_span(buf, offset, 4)
    return struct.unpack_from("<I", buf, offset)[0], offset + 4


def read_u64(buf, offset):
    require_span(buf, offset, 8)
    return struct.unpack_from("<Q", buf, offset)[0], offset + 8


def read_string(buf, offset):
    length, offset = read_u64(buf, offset)
    require_span(buf, offset, length)
    raw = bytes(buf[offset:offset + length])
    return raw.decode("utf-8"), offset + length


def skip_value(buf, offset, value_type):
    if value_type == GGUF_TYPE_STRING:
        _, offset = read_string(buf, offset)
        return offset

    if value_type == GGUF_TYPE_ARRAY:
        elem_type, offset = read_u32(buf, offset)
        count, offset = read_u64(buf, offset)
        if elem_type == GGUF_TYPE_STRING:
            for _ in range(count):
                _, offset = read_string(buf, offset)
            return offset
        require(elem_type in SCALAR_TYPE_BYTES,
                f"unsupported GGUF array element type {elem_type}")
        size = SCALAR_TYPE_BYTES[elem_type] * count
        require_span(buf, offset, size)
        return offset + size

    require(value_type in SCALAR_TYPE_BYTES,
            f"unsupported GGUF metadata type {value_type}")
    require_span(buf, offset, SCALAR_TYPE_BYTES[value_type])
    return offset + SCALAR_TYPE_BYTES[value_type]


def read_alignment(buf, offset, value_type):
    if value_type == GGUF_TYPE_UINT32:
        value, _ = read_u32(buf, offset)
        return value
    if value_type == GGUF_TYPE_UINT64:
        value, _ = read_u64(buf, offset)
        return value
    if value_type == GGUF_TYPE_INT32:
        require_span(buf, offset, 4)
        return struct.unpack_from("<i", buf, offset)[0]
    if value_type == GGUF_TYPE_INT64:
        require_span(buf, offset, 8)
        return struct.unpack_from("<q", buf, offset)[0]
    return None


def parse_gguf(buf):
    require_span(buf, 0, 24)
    magic, version, tensor_count, metadata_count = struct.unpack_from(
        "<IIQQ", buf, 0)
    require(magic == 0x46554747, "bad GGUF magic")
    require(version == 3, f"unsupported GGUF version {version}")

    offset = 24
    alignment = 32
    epsilon_bits = None

    for _ in range(metadata_count):
        key, offset = read_string(buf, offset)
        value_type, offset = read_u32(buf, offset)

        if key == EPSILON_KEY and value_type == GGUF_TYPE_FLOAT32:
            require_span(buf, offset, 4)
            epsilon_bits = struct.unpack_from("<I", buf, offset)[0]
        elif key == "general.alignment":
            parsed_alignment = read_alignment(buf, offset, value_type)
            if parsed_alignment is not None:
                alignment = parsed_alignment

        offset = skip_value(buf, offset, value_type)

    require(epsilon_bits is not None, f"missing {EPSILON_KEY}")
    require(alignment > 0 and alignment & (alignment - 1) == 0,
            f"unsupported tensor-data alignment {alignment}")

    tensors = {}
    for _ in range(tensor_count):
        name, offset = read_string(buf, offset)
        n_dims, offset = read_u32(buf, offset)
        require(0 < n_dims <= 4, f"bad dimension count for {name}: {n_dims}")
        dims = []
        for _ in range(n_dims):
            dim, offset = read_u64(buf, offset)
            dims.append(dim)
        ggml_type, offset = read_u32(buf, offset)
        tensor_offset, offset = read_u64(buf, offset)
        tensors[name] = {
            "dims": dims,
            "type": ggml_type,
            "offset": tensor_offset,
        }

    tensor_data_offset = align_up(offset, alignment)
    require(tensor_data_offset < len(buf),
            "tensor data starts outside the mapped file")

    return tensor_data_offset, epsilon_bits, tensors


def require_tensor(tensors, name, ggml_type, dims_len):
    require(name in tensors, f"missing tensor {name}")
    tensor = tensors[name]
    require(tensor["type"] == ggml_type,
            f"{name} type {tensor['type']} != {ggml_type}")
    require(len(tensor["dims"]) == dims_len,
            f"{name} dimension count {len(tensor['dims'])} != {dims_len}")
    return tensor


def q8_0_row_bytes(width):
    require(width > 0 and width % Q8_0_BLOCK_VALUES == 0,
            f"Q8_0 row width is not a positive multiple of 32: {width}")
    return (width // Q8_0_BLOCK_VALUES) * Q8_0_BLOCK_BYTES


def tensor_pointer(buf, tensor_data_offset, tensor, byte_size):
    start = tensor_data_offset + tensor["offset"]
    require(start >= tensor_data_offset, "tensor offset wrapped")
    require_span(buf, start, byte_size)
    return start


def half_scale(buf, offset):
    require_span(buf, offset, 2)
    return f32(np.frombuffer(buf, dtype="<f2", count=1, offset=offset)[0])


def dequant_q8_0_row(buf, row_start, width):
    output = np.empty(width, dtype=np.float32)
    block_count = width // Q8_0_BLOCK_VALUES
    out_index = 0

    for block in range(block_count):
        block_start = row_start + block * Q8_0_BLOCK_BYTES
        scale = half_scale(buf, block_start)
        for i in range(Q8_0_BLOCK_VALUES):
            quant = struct.unpack_from("<b", buf, block_start + 2 + i)[0]
            value = f32(f32(quant) * scale)
            output[out_index] = value
            out_index += 1

    return output


def rmsnorm(input_row, weight_row, epsilon):
    total = f32(0.0)
    for value in input_row:
        squared = f32(value * value)
        total = f32(total + squared)

    count = f32(len(input_row))
    mean_square = f32(total / count)
    shifted = f32(mean_square + epsilon)
    root = f32(np.sqrt(shifted))
    scale = f32(f32(1.0) / root)

    output = np.empty_like(input_row)
    for i, value in enumerate(input_row):
        normalized = f32(value * scale)
        output[i] = f32(normalized * weight_row[i])

    return output


def q8_0_dot_row(buf, row_start, activation):
    total = f32(0.0)
    block_count = len(activation) // Q8_0_BLOCK_VALUES

    for block in range(block_count):
        block_start = row_start + block * Q8_0_BLOCK_BYTES
        scale = half_scale(buf, block_start)
        activation_base = block * Q8_0_BLOCK_VALUES
        for i in range(Q8_0_BLOCK_VALUES):
            quant = struct.unpack_from("<b", buf, block_start + 2 + i)[0]
            dequant = f32(f32(quant) * scale)
            product = f32(dequant * activation[activation_base + i])
            total = f32(total + product)

    return total


def run_oracle(path):
    fd = os.open(path, os.O_RDONLY)
    try:
        with mmap.mmap(fd, 0, access=mmap.ACCESS_READ) as buf:
            tensor_data_offset, epsilon_bits, tensors = parse_gguf(buf)
            token_embd = require_tensor(tensors, TOKEN_EMBD, GGML_TYPE_Q8_0, 2)
            attn_norm = require_tensor(tensors, ATTN_NORM, GGML_TYPE_F32, 1)
            attn_q = require_tensor(tensors, ATTN_Q, GGML_TYPE_Q8_0, 2)

            width = token_embd["dims"][0]
            token_rows = token_embd["dims"][1]
            require(token_rows > 0, "token embedding tensor has no rows")
            require(attn_norm["dims"][0] == width,
                    "attention RMSNorm width mismatch")
            require(attn_q["dims"][0] == width,
                    "attention query input width mismatch")
            require(attn_q["dims"][1] >= 4,
                    "attention query tensor has fewer than four rows")

            token_row_bytes = q8_0_row_bytes(width)
            token_start = tensor_pointer(buf, tensor_data_offset, token_embd,
                                         token_row_bytes * token_rows)
            norm_start = tensor_pointer(buf, tensor_data_offset, attn_norm,
                                        width * 4)
            attn_q_row_bytes = q8_0_row_bytes(attn_q["dims"][0])
            attn_q_start = tensor_pointer(buf, tensor_data_offset, attn_q,
                                          attn_q_row_bytes * attn_q["dims"][1])

            token0 = dequant_q8_0_row(buf, token_start, width)
            norm_weight = np.frombuffer(buf, dtype="<f4", count=width,
                                        offset=norm_start).copy()
            normalized = rmsnorm(token0, norm_weight, f32_from_bits(epsilon_bits))

            outputs = []
            for row in range(4):
                row_start = attn_q_start + row * attn_q_row_bytes
                outputs.append(q8_0_dot_row(buf, row_start, normalized))

            return {
                "tensor_data_offset": tensor_data_offset,
                "epsilon_bits": epsilon_bits,
                TOKEN_EMBD: token_embd,
                ATTN_NORM: attn_norm,
                ATTN_Q: attn_q,
                "outputs": outputs,
            }
    finally:
        os.close(fd)


def main():
    parser = argparse.ArgumentParser(
        description="Print external token0 attention query oracle words.")
    parser.add_argument("model", help="path to the target Q8_0 GGUF model")
    args = parser.parse_args()

    result = run_oracle(args.model)

    print(f"tensor_data_offset: {result['tensor_data_offset']}")
    print(f"attn_norm_rms_epsilon_f32_hex: "
          f"0x{result['epsilon_bits']:08x}")
    for label in (TOKEN_EMBD, ATTN_NORM, ATTN_Q):
        tensor = result[label]
        dims = "x".join(str(dim) for dim in tensor["dims"])
        print(f"{label}: type {tensor['type']} dims {dims} "
              f"offset {tensor['offset']}")
    for index, value in enumerate(result["outputs"]):
        print(f"oracle_token0_attn_q_output{index}_f32_hex: "
              f"0x{f32_bits(value):08x}")


if __name__ == "__main__":
    main()
