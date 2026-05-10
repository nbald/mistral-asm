AS ?= as
LD ?= ld

ASFLAGS ?= --64
LDFLAGS ?=

TARGET := mistral-asm
BUILD_DIR := build

ASM_SOURCES := \
	src/entry/_start.s \
	src/gguf/load_header.s \
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

$(BUILD_DIR)/tests/%.o: tests/%.s
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
