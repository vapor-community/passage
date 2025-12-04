#!/bin/bash

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Running tests with coverage...${NC}"
swift test --enable-code-coverage

BINARY_PATH=".build/debug/passagePackageTests.xctest/Contents/MacOS/passagePackageTests"
PROFDATA_PATH=".build/debug/codecov/default.profdata"

# Check if binary exists
if [ ! -f "$BINARY_PATH" ]; then
    echo -e "${RED}❌ Test binary not found at: $BINARY_PATH${NC}"
    exit 1
fi

# Check if profdata exists
if [ ! -f "$PROFDATA_PATH" ]; then
    echo -e "${RED}❌ Coverage data not found at: $PROFDATA_PATH${NC}"
    exit 1
fi

echo -e "\n${BLUE}📊 Coverage Report for Passage Module${NC}"
echo -e "${BLUE}========================================${NC}\n"

# Generate coverage report for Passage module only
xcrun llvm-cov report "$BINARY_PATH" \
  -instr-profile="$PROFDATA_PATH" \
  Sources/Passage

# Generate HTML report
echo -e "\n${BLUE}📁 Generating HTML report...${NC}"
xcrun llvm-cov show "$BINARY_PATH" \
  -instr-profile="$PROFDATA_PATH" \
  -format=html \
  -output-dir=coverage-report \
  Sources/Passage

echo -e "\n${GREEN}✅ Coverage report generated!${NC}"
echo -e "${YELLOW}📂 HTML Report: coverage-report/index.html${NC}"
echo -e "${YELLOW}📂 Summary above shows Passage module only${NC}"

# Optional: Open in browser (comment out if you don't want auto-open)
if command -v open &> /dev/null; then
    echo -e "\n${BLUE}🌐 Opening in browser...${NC}"
    open coverage-report/index.html
fi

# Generate LCOV format for CI/CD tools
echo -e "\n${BLUE}📄 Generating LCOV format...${NC}"
xcrun llvm-cov export "$BINARY_PATH" \
  -instr-profile="$PROFDATA_PATH" \
  -format=lcov \
  Sources/Passage > coverage.lcov

echo -e "${GREEN}✅ LCOV report generated: coverage.lcov${NC}"
