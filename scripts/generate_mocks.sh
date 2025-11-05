#!/bin/bash

# Script to generate mock files for tests
# Run this script after adding new @GenerateMocks annotations to test files

set -e

echo "🔧 Generating mock files for tests..."
echo ""

# Clean previous builds
echo "Cleaning previous builds..."
flutter pub run build_runner clean

# Generate mocks
echo "Generating mocks..."
flutter pub run build_runner build --delete-conflicting-outputs

echo ""
echo "✅ Mock generation complete!"
echo ""
echo "You can now run tests with:"
echo "  flutter test"
echo ""
echo "Or run tests with coverage:"
echo "  flutter test --coverage"
