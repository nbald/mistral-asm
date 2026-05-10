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
	src/sys/close.s \
	src/sys/exit.s \
	src/sys/fstat.s \
	src/sys/mmap.s \
	src/sys/munmap.s \
	src/sys/openat.s \
	src/sys/write.s

OBJECTS := $(ASM_SOURCES:src/%.s=$(BUILD_DIR)/%.o)
Q8_0_DOT_CHECK := $(BUILD_DIR)/tests/q8_0_dot_check
Q8_0_DOT_CHECK_OBJECTS := \
	$(BUILD_DIR)/tests/q8_0_dot_harness.o \
	$(BUILD_DIR)/math/q8_0_dot.o \
	$(BUILD_DIR)/sys/exit.o \
	$(BUILD_DIR)/sys/write.o

.PHONY: all clean check check-q8_0-dot

all: $(TARGET)

check: check-q8_0-dot

check-q8_0-dot: $(Q8_0_DOT_CHECK)
	$(Q8_0_DOT_CHECK)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(Q8_0_DOT_CHECK): $(Q8_0_DOT_CHECK_OBJECTS)
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
