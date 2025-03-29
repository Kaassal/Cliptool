#!/bin/sh

# Exit on first error
set -e

# Check dependencies
check_deps() {
    command -v xclip >/dev/null 2>&1 || {
        echo "Error: xclip not found. Install with: sudo apt install xclip"
        exit 1
    }
    
    command -v ct >/dev/null 2>&1 || {
        echo "Error: ct not found in PATH. Install first with: make install"
        exit 1
    }
}

# Clipboard verification
verify_clipboard() {
    expected="$1"
    actual=$(xclip -selection clipboard -o 2>/dev/null)
    
    if [ "$actual" != "$expected" ]; then
        echo "FAIL: Clipboard content mismatch"
        echo "Expected: '$expected'"
        echo "Actual:   '$actual'"
        return 1
    fi
    return 0
}

# Test cases
test_basic_copy() {
    echo "Running test_basic_copy..."
    echo "test123" | ct
    verify_clipboard "test123"
}

test_command_capture() {
    echo "Running test_command_capture..."
    test_cmd="echo 'command test'"
    $test_cmd | ct -b
    verify_clipboard "Command:\n$test_cmd\n\nOutput:\ncommand test"
}

test_markdown_inline() {
    echo "Running test_markdown_inline..."
    echo "mdtest" | ct -m
    verify_clipboard "`mdtest`"
}

test_markdown_block() {
    echo "Running test_markdown_block..."
    echo "mdblock\ntest" | ct -M
    verify_clipboard "```\nmdblock\ntest\n```"
}

test_command_only() {
    echo "Running test_command_only..."
    test_cmd="ls -l"
    $test_cmd | ct -c
    verify_clipboard "$test_cmd"
}

test_help_output() {
    echo "Running test_help_output..."
    output=$(ct || true)  # Ignore exit code
    if ! echo "$output" | grep -q "ct - Tee-like tool with clipboard integration"; then
        echo "FAIL: Help output not detected"
        return 1
    fi
    return 0
}

# Clean clipboard
cleanup() {
    echo "" | xclip -selection clipboard
}

main() {
    check_deps
    trap cleanup EXIT
    
    tests="
        test_basic_copy
        test_command_capture
        test_markdown_inline
        test_markdown_block
        test_command_only
        test_help_output
    "
    
    failures=0
    for test in $tests; do
        if ! $test; then
            failures=$((failures + 1))
        fi
        cleanup
    done
    
    echo "\nTest summary:"
    echo "Total tests: $(echo "$tests" | wc -w)"
    echo "Passed: $(( $(echo "$tests" | wc -w) - failures ))"
    echo "Failed: $failures"
    
    exit $((failures > 0 ? 1 : 0))
}

main "$@":