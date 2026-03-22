# Sindarin Collections Package - Makefile
#
# Pure Sindarin collections library.
# Dependencies are managed via sn.yaml package references.

#------------------------------------------------------------------------------
# Phony targets
#------------------------------------------------------------------------------
.PHONY: all test clean help benchmark benchmark-asan benchmark-valgrind benchmark-massif

# Disable implicit rules for .sn.c files (these are compiled by the Sindarin compiler)
%.sn: %.sn.c
	@:

#------------------------------------------------------------------------------
# Platform Detection
#------------------------------------------------------------------------------
ifeq ($(OS),Windows_NT)
    PLATFORM := windows
    EXE_EXT := .exe
    MKDIR := mkdir
else
    UNAME_S := $(shell uname -s 2>/dev/null || echo Unknown)
    ifeq ($(UNAME_S),Darwin)
        PLATFORM := darwin
    else
        PLATFORM := linux
    endif
    EXE_EXT :=
    MKDIR := mkdir -p
endif

#------------------------------------------------------------------------------
# Configuration
#------------------------------------------------------------------------------
BIN_DIR := bin

# Sindarin compiler (from PATH, or override with SN=path/to/sn)
SN ?= sn

# Test runner from sindarin-pkg-test dependency
RUN_TESTS_SN := .sn/sindarin-pkg-test/src/execute.sn

# Source files (for dependency tracking)
SRC_SOURCES := $(wildcard src/*.sn)

# Compiled script binaries
RUN_TESTS_BIN := $(BIN_DIR)/run_tests$(EXE_EXT)

#------------------------------------------------------------------------------
# Default target
#------------------------------------------------------------------------------
all: test

#------------------------------------------------------------------------------
# test - Run self-tests using compiled Sindarin test runner
#------------------------------------------------------------------------------
test: $(RUN_TESTS_BIN)
	@$(RUN_TESTS_BIN)

#------------------------------------------------------------------------------
# Build the test runner
#------------------------------------------------------------------------------
$(BIN_DIR):
	@$(MKDIR) $(BIN_DIR)

$(RUN_TESTS_BIN): $(RUN_TESTS_SN) $(SRC_SOURCES) | $(BIN_DIR)
	@echo "Compiling execute.sn..."
	@$(SN) $(RUN_TESTS_SN) -o $(RUN_TESTS_BIN) -l 1

#------------------------------------------------------------------------------
# clean - Remove build artifacts
#------------------------------------------------------------------------------
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf $(BIN_DIR)
	@echo "Clean complete."

#------------------------------------------------------------------------------
# benchmark - Run benchmarks (optimized build, no ASAN)
#------------------------------------------------------------------------------
BENCH_SN := benchmarks/bench.sn
BENCH_BIN := $(BIN_DIR)/bench$(EXE_EXT)
BENCH_ASAN_BIN := $(BIN_DIR)/bench_asan$(EXE_EXT)

benchmark: | $(BIN_DIR)
	@echo "Compiling benchmark (optimized, no ASAN)..."
	@$(SN) $(BENCH_SN) -o $(BENCH_BIN) -l 1
	@echo ""
	@/usr/bin/time -v ./$(BENCH_BIN) 2> /tmp/collections_bench_time.txt; \
	echo ""; \
	PEAK_MEM=$$(grep "Maximum resident set size" /tmp/collections_bench_time.txt 2>/dev/null | awk '{print $$6}'); \
	USER_TIME=$$(grep "User time" /tmp/collections_bench_time.txt 2>/dev/null | awk '{print $$4}'); \
	SYS_TIME=$$(grep "System time" /tmp/collections_bench_time.txt 2>/dev/null | awk '{print $$4}'); \
	CPU_TIME=$$(echo "$${USER_TIME:-0} + $${SYS_TIME:-0}" | bc 2>/dev/null || echo "N/A"); \
	echo "  Resources"; \
	echo "  -----------------------------------------"; \
	printf "  %-16s %s KB\n" "Peak Memory:" "$${PEAK_MEM:-N/A}"; \
	printf "  %-16s %s s\n" "CPU Time:" "$${CPU_TIME:-N/A}"; \
	echo ""; \
	rm -f /tmp/collections_bench_time.txt

#------------------------------------------------------------------------------
# benchmark-asan - Run benchmarks with ASAN for memory leak detection
#------------------------------------------------------------------------------
benchmark-asan: | $(BIN_DIR)
	@echo "Compiling benchmark (ASAN enabled)..."
	@$(SN) $(BENCH_SN) -o $(BENCH_ASAN_BIN) -g -l 1
	@echo ""
	@TMPDIR=$$(mktemp -d); \
	/usr/bin/time -v ./$(BENCH_ASAN_BIN) > "$$TMPDIR/stdout.txt" 2> "$$TMPDIR/stderr.txt"; \
	EXIT_CODE=$$?; \
	cat "$$TMPDIR/stdout.txt"; \
	echo ""; \
	PEAK_MEM=$$(grep "Maximum resident set size" "$$TMPDIR/stderr.txt" 2>/dev/null | awk '{print $$6}'); \
	USER_TIME=$$(grep "User time" "$$TMPDIR/stderr.txt" 2>/dev/null | awk '{print $$4}'); \
	SYS_TIME=$$(grep "System time" "$$TMPDIR/stderr.txt" 2>/dev/null | awk '{print $$4}'); \
	CPU_TIME=$$(echo "$${USER_TIME:-0} + $${SYS_TIME:-0}" | bc 2>/dev/null || echo "N/A"); \
	echo "  Resources"; \
	echo "  -----------------------------------------"; \
	printf "  %-16s %s KB\n" "Peak Memory:" "$${PEAK_MEM:-N/A}"; \
	printf "  %-16s %s s\n" "CPU Time:" "$${CPU_TIME:-N/A}"; \
	echo ""; \
	if grep -qE "AddressSanitizer|LeakSanitizer" "$$TMPDIR/stderr.txt" 2>/dev/null; then \
		echo "  ASAN Report"; \
		echo "  -----------------------------------------"; \
		grep -A5 "ERROR\|SUMMARY\|LeakSanitizer" "$$TMPDIR/stderr.txt" 2>/dev/null; \
		echo ""; \
		rm -rf "$$TMPDIR"; \
		exit 1; \
	else \
		echo "  ASAN: No errors detected"; \
		echo ""; \
	fi; \
	rm -rf "$$TMPDIR"

#------------------------------------------------------------------------------
# benchmark-valgrind - Run benchmarks under valgrind memcheck (leak detection)
#------------------------------------------------------------------------------
benchmark-valgrind: $(BENCH_BIN)
	@echo ""
	@echo "Running benchmark under valgrind memcheck..."
	@echo ""
	@valgrind --leak-check=full --show-leak-kinds=all --error-exitcode=1 \
		./$(BENCH_BIN) 2>&1 | tee /tmp/collections_valgrind.txt; \
	EXIT_CODE=$$?; \
	echo ""; \
	echo "  Valgrind Summary"; \
	echo "  -----------------------------------------"; \
	grep -E "HEAP SUMMARY|in use at exit|total heap|All heap|definitely|indirectly|possibly|ERROR SUMMARY" \
		/tmp/collections_valgrind.txt 2>/dev/null | sed 's/^==[0-9]*==//'; \
	echo ""; \
	rm -f /tmp/collections_valgrind.txt; \
	if [ $$EXIT_CODE -ne 0 ]; then echo "  RESULT: LEAKS DETECTED"; exit 1; \
	else echo "  RESULT: No leaks"; fi; \
	echo ""

#------------------------------------------------------------------------------
# benchmark-massif - Run benchmarks under valgrind massif (heap profiling)
#------------------------------------------------------------------------------
MASSIF_OUT := /tmp/collections_massif.out

benchmark-massif: $(BENCH_BIN)
	@echo ""
	@echo "Running benchmark under valgrind massif..."
	@echo ""
	@valgrind --tool=massif --pages-as-heap=yes --massif-out-file=$(MASSIF_OUT) \
		./$(BENCH_BIN) 2>&1 | grep -v "^==" ; \
	echo ""; \
	echo "  Massif Heap Profile"; \
	echo "  -----------------------------------------"; \
	ms_print $(MASSIF_OUT) 2>/dev/null | head -30; \
	echo ""; \
	PEAK=$$(ms_print $(MASSIF_OUT) 2>/dev/null | grep "^  .*(peak)" | head -1); \
	echo "  Peak snapshot: $$PEAK"; \
	echo "  Full report:   ms_print $(MASSIF_OUT)"; \
	echo ""

#------------------------------------------------------------------------------
# help - Show available targets
#------------------------------------------------------------------------------
help:
	@echo "Sindarin Collections Package"
	@echo ""
	@echo "Targets:"
	@echo "  make test               Run self-tests"
	@echo "  make benchmark          Run benchmarks (optimized)"
	@echo "  make benchmark-asan     Run benchmarks with ASAN (memory safety)"
	@echo "  make benchmark-valgrind Run benchmarks with valgrind memcheck (leak detection)"
	@echo "  make benchmark-massif   Run benchmarks with valgrind massif (heap profiling)"
	@echo "  make clean              Remove build artifacts"
	@echo "  make help               Show this help"
	@echo ""
	@echo "Dependencies are managed via sn.yaml package references."
	@echo ""
	@echo "Platform: $(PLATFORM)"
