#!/bin/zsh
#
# Runs local checks (format, analyze, test, debug builds) similar to CI.
# Run this script from the project root directory.

set -e # Exit immediately if a command exits with a non-zero status.

echo "--- Running Local CI Checks ---"

# Ensure dependencies are up-to-date
echo "\n---> Installing dependencies..."
flutter pub get

# Generate code (if needed)
echo "\n---> Running build_runner..."
flutter pub run build_runner build --delete-conflicting-outputs

# Check formatting
echo "\n---> Checking code format..."
dart format --set-exit-if-changed .

# Run static analysis
echo "\n---> Running static analysis..."
dart analyze

# Run tests (unit and widget)
echo "\n---> Running tests..."
flutter test

# Check debug builds
echo "\n---> Checking Android debug build..."
flutter build apk --debug

echo "\n---> Checking iOS debug build (requires macOS)..."
# Uncomment the following line if running on macOS
# flutter build ios --debug --no-codesign
# Check if running on macOS before attempting iOS build
if [[ "$(uname)" == "Darwin" ]]; then
  echo "  (Running on macOS, attempting build)"
  flutter build ios --debug --no-codesign
else
  echo "  (Skipping iOS build check - not on macOS)"
fi

echo "\n--- Local CI Checks Passed Successfully! ---" 