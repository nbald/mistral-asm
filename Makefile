AS ?= as
LD ?= ld

ASFLAGS ?= --64
LDFLAGS ?=

TARGET := mistral-asm
BUILD_DIR := build

ASM_SOURCES := \
	src/entry/_start.s \
	src/gguf/load_header.s \
	src/infer/token0_layer2_attn.s \
	src/infer/token0_layer2_attn_context.s \
	src/infer/token0_layer2_attn_output.s \
	src/infer/token0_layer2_post_attn_residual.s \
	src/infer/token0_layer2_ffn.s \
	src/infer/token0_layer2_ffn_down.s \
	src/infer/token0_layer1_ffn_down.s \
	src/infer/token0_layer1_ffn.s \
	src/math/q8_0_dot.s \
	src/math/rmsnorm.s \
	src/math/swiglu.s \
	src/runtime/text.s \
	src/sys/close.s \
	src/sys/exit.s \
	src/sys/fstat.s \
	src/sys/mmap.s \
	src/sys/munmap.s \
	src/sys/openat.s \
	src/sys/write.s

ENTRY_START_INCLUDES := \
	src/entry/start/constants.inc \
	src/entry/start/rodata.inc \
	src/entry/start/state.inc \
	src/entry/start/main.inc \
	src/entry/start/lookup_summary.inc \
	src/entry/start/output_slices.inc \
	src/entry/start/token0_smokes.inc \
	src/entry/start/gnu_stack.inc

ENTRY_LOOKUP_SUMMARY_INCLUDES := \
	src/entry/start/lookup_summary/layer2.inc \
	src/entry/start/lookup_summary/layer3.inc

ENTRY_RODATA_INCLUDES := \
	src/entry/start/rodata/cli_requests.inc \
	src/entry/start/rodata/layer3_cli_requests.inc \
	src/entry/start/rodata/summary_labels.inc \
	src/entry/start/rodata/layer3_summary_labels.inc \
	src/entry/start/rodata/layer0_tensor_labels.inc \
	src/entry/start/rodata/smoke_status_labels.inc \
	src/entry/start/rodata/slice_labels.inc \
	src/entry/start/rodata/common_error_labels.inc

ENTRY_STATE_INCLUDES := \
	src/entry/start/state/layer3_globals.inc \
	src/entry/start/state/layer3_bss.inc

ENTRY_MAIN_INCLUDES := \
	src/entry/start/main/bootstrap.inc \
	src/entry/start/main/bootstrap/layer3.inc \
	src/entry/start/main/summary_header.inc \
	src/entry/start/main/summary_first_lookup.inc \
	src/entry/start/main/summary_layer0_attn_tensors.inc \
	src/entry/start/main/summary_layer0_ffn_tensors.inc \
	src/entry/start/main/smoke_orchestration.inc \
	src/entry/start/main/exit.inc

ENTRY_OUTPUT_SLICE_INCLUDES := \
	src/entry/start/output_slices/layer0_attn.inc \
	src/entry/start/output_slices/layer0_ffn.inc \
	src/entry/start/output_slices/layer1_attn.inc

ENTRY_TOKEN0_SMOKE_INCLUDES := \
	src/entry/start/token0_smokes/layer0_attn.inc \
	src/entry/start/token0_smokes/layer0_ffn.inc \
	src/entry/start/token0_smokes/layer1_attn.inc

ENTRY_START_ALL_INCLUDES := \
	$(ENTRY_START_INCLUDES) \
	$(ENTRY_LOOKUP_SUMMARY_INCLUDES) \
	$(ENTRY_RODATA_INCLUDES) \
	$(ENTRY_STATE_INCLUDES) \
	$(ENTRY_MAIN_INCLUDES) \
	$(ENTRY_OUTPUT_SLICE_INCLUDES) \
	$(ENTRY_TOKEN0_SMOKE_INCLUDES)

GGUF_LOAD_HEADER_INCLUDES := \
	src/gguf/load_header/constants.inc \
	src/gguf/load_header/rodata.inc \
	src/gguf/load_header/mapping.inc \
	src/gguf/load_header/metadata_walk.inc \
	src/gguf/load_header/tensor_infos.inc \
	src/gguf/load_header/lookup.inc \
	src/gguf/load_header/skip_helpers.inc \
	src/gguf/load_header/gnu_stack.inc

OBJECTS := $(ASM_SOURCES:src/%.s=$(BUILD_DIR)/%.o)
Q8_0_DOT_CHECK := $(BUILD_DIR)/tests/q8_0_dot_check
RMSNORM_CHECK := $(BUILD_DIR)/tests/rmsnorm_check
SWIGLU_CHECK := $(BUILD_DIR)/tests/swiglu_check
GGUF_LOOKUP_CHECK := $(BUILD_DIR)/tests/gguf_lookup_check
Q8_0_DOT_CHECK_OBJECTS := \
	$(BUILD_DIR)/tests/q8_0_dot_harness.o \
	$(BUILD_DIR)/math/q8_0_dot.o \
	$(BUILD_DIR)/sys/exit.o \
	$(BUILD_DIR)/sys/write.o
RMSNORM_CHECK_OBJECTS := \
	$(BUILD_DIR)/tests/rmsnorm_harness.o \
	$(BUILD_DIR)/math/rmsnorm.o \
	$(BUILD_DIR)/sys/exit.o \
	$(BUILD_DIR)/sys/write.o
SWIGLU_CHECK_OBJECTS := \
	$(BUILD_DIR)/tests/swiglu_harness.o \
	$(BUILD_DIR)/math/swiglu.o \
	$(BUILD_DIR)/sys/exit.o \
	$(BUILD_DIR)/sys/write.o
GGUF_LOOKUP_CHECK_OBJECTS := \
	$(BUILD_DIR)/tests/gguf_lookup_harness.o \
	$(BUILD_DIR)/gguf/load_header.o \
	$(BUILD_DIR)/sys/close.o \
	$(BUILD_DIR)/sys/exit.o \
	$(BUILD_DIR)/sys/fstat.o \
	$(BUILD_DIR)/sys/mmap.o \
	$(BUILD_DIR)/sys/munmap.o \
	$(BUILD_DIR)/sys/openat.o \
	$(BUILD_DIR)/sys/write.o

.PHONY: all clean check check-q8_0-dot check-rmsnorm check-swiglu check-gguf-lookup

all: $(TARGET)

check: check-q8_0-dot check-rmsnorm check-swiglu check-gguf-lookup

check-q8_0-dot: $(Q8_0_DOT_CHECK)
	$(Q8_0_DOT_CHECK)

check-rmsnorm: $(RMSNORM_CHECK)
	$(RMSNORM_CHECK)

check-swiglu: $(SWIGLU_CHECK)
	$(SWIGLU_CHECK)

check-gguf-lookup: $(GGUF_LOOKUP_CHECK)
	$(GGUF_LOOKUP_CHECK)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(Q8_0_DOT_CHECK): $(Q8_0_DOT_CHECK_OBJECTS)
	mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

$(RMSNORM_CHECK): $(RMSNORM_CHECK_OBJECTS)
	mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

$(SWIGLU_CHECK): $(SWIGLU_CHECK_OBJECTS)
	mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

$(GGUF_LOOKUP_CHECK): $(GGUF_LOOKUP_CHECK_OBJECTS)
	mkdir -p $(dir $@)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: src/%.s
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

$(BUILD_DIR)/entry/_start.o: $(ENTRY_START_ALL_INCLUDES)

$(BUILD_DIR)/gguf/load_header.o: $(GGUF_LOAD_HEADER_INCLUDES)

$(BUILD_DIR)/tests/%.o: tests/%.s
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
