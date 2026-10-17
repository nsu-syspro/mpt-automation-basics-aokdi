CC := gcc
BUILD_DIR := build
CONFIG := config.json

NAME := $(shell jq -r '.name' $(CONFIG))
VERSION := $(shell jq -r '.version' $(CONFIG))

TARGET := $(BUILD_DIR)/$(NAME)
SOURCE := src/wordcount.c

CFLAGS ?= -Wall -Wextra
CPPFLAGS += -DNAME='"$(NAME)"' -DVERSION='"$(VERSION)"'

.DEFAULT_GOAL := all

.PHONY: all clean check

all: $(TARGET)

$(TARGET): $(SOURCE) $(CONFIG) | $(BUILD_DIR)
	$(CC) $(CPPFLAGS) $(CFLAGS) $(SOURCE) -o $@

$(BUILD_DIR):
	mkdir -p $@

clean:
	rm -rf $(BUILD_DIR)


check: $(TARGET)
	@set -eu; \
	tmpdir=$$(mktemp -d); \
	trap 'rm -rf "$$tmpdir"' EXIT HUP INT TERM; \
	for input in test/*.txt; do \
		expected="$${input%.txt}.expected"; \
		actual="$$tmpdir/output"; \
		"$(TARGET)" "$$input" > "$$actual"; \
		if ! diff -u "$$expected" "$$actual"; then \
			exit 1; \
		fi; \
	done
