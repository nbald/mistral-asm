AS ?= as
LD ?= ld

ASFLAGS ?= --64
LDFLAGS ?=

TARGET := mistral-asm
BUILD_DIR := build

ASM_SOURCES := \
	src/entry/_start.s \
	src/sys/exit.s \
	src/sys/write.s

OBJECTS := $(ASM_SOURCES:src/%.s=$(BUILD_DIR)/%.o)

.PHONY: all clean

all: $(TARGET)

$(TARGET): $(OBJECTS)
	$(LD) $(LDFLAGS) -o $@ $^

$(BUILD_DIR)/%.o: src/%.s
	mkdir -p $(dir $@)
	$(AS) $(ASFLAGS) -o $@ $<

clean:
	rm -rf $(BUILD_DIR) $(TARGET)
