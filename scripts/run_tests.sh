#!/bin/bash

# Script to run all tests with coverage
# This script will run unit tests, widget tests, and generate coverage report

set -e

echo "🧪 Running HouseBart Test Suite"
echo ""

# Run tests with coverage
echo "Running tests with coverage..."
flutter test --coverage

# Check if lcov is installed
if command -v lcov &> /dev/null; then
  echo ""
  echo "Generating HTML coverage report..."
  genhtml coverage/lcov.info -o coverage/html

  echo ""
  echo "✅ Tests complete! Coverage report generated at coverage/html/index.html"
  echo ""
  echo "To view coverage report:"
  echo "  macOS: open coverage/html/index.html"
  echo "  Linux: xdg-open coverage/html/index.html"
  echo "  Windows: start coverage/html/index.html"
else
  echo ""
  echo "⚠️  lcov not installed. Coverage HTML report not generated."
  echo "Install lcov:"
  echo "  Ubuntu/Debian: sudo apt-get install lcov"
  echo "  macOS: brew install lcov"
fi

echo ""
echo "📊 Test Summary:"
flutter test --coverage 2>&1 | grep -E "(passed|failed|All tests passed)"
