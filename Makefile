CC := gcc
BUILD_DIR := build
CONFIG := config.json

NAME := $(shell jq -r '.name' $(CONFIG))
VERSION := $(shell jq -r '.version' $(CONFIG))

TARGET := $(BUILD_DIR)/$(NAME)
SOURCE := src/wordcount.c

CFLAGS ?= -Wall -Wextra

TEST_FILES := $(wildcard test/*.txt)
TEST_NAMES := $(patsubst test/%.txt,%,$(TEST_FILES))
TEST_TARGETS := $(addprefix check-,$(TEST_NAMES))

.DEFAULT_GOAL := all

.PHONY: all clean check

all: $(TARGET)

$(TARGET): $(SOURCE) $(CONFIG) | $(BUILD_DIR)
	$(CC) $(CFLAGS) $(SOURCE) -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)

check: $(TEST_TARGETS)

check-%: test/%.txt test/%.expected $(TARGET)
	@set -eu; \
	if ! (./$(TARGET) test/$*.txt | diff -u test/$*.expected -); then \
		exit 1; \
	fi
