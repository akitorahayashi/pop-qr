#!/bin/bash
set -e

# === Configuration ===
OUTPUT_DIR="ci-outputs/test-results"
IOS_DERIVED_DATA_PATH="$OUTPUT_DIR/DerivedData" # Path where Xcode build artifacts are stored

# === Helper Functions ===
step() {
  echo ""
  echo "──────────────────────────────────────────────────────────────────────"
  echo "▶️  $1"
  echo "──────────────────────────────────────────────────────────────────────"
}

success() {
  echo "✅ $1"
}

fail() {
  echo "❌ Error: $1"
  exit 1
}

# === Argument Parsing ===
RUN_PUB_GET=true
RUN_BUILD_RUNNER=true
RUN_FORMAT=true
RUN_ANALYZE=true
RUN_UNIT_TEST=false
RUN_UI_TEST=false # Assuming UI tests are separate and need explicit activation
RUN_BUILD_DEBUG=false
RUN_ARCHIVE=false
TEST_WITHOUT_BUILDING=false
BUILD_FOR_TESTING=false

# Default: Run all standard checks if no specific flags are given
if [ $# -eq 0 ]; then
  RUN_UNIT_TEST=true
  # RUN_UI_TEST=true # Enable this if you want UI tests to run by default
  RUN_BUILD_DEBUG=true # Build debug versions by default
  # RUN_ARCHIVE=true # Archive is likely less common, don't run by default
else
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
      --all-tests)
        RUN_UNIT_TEST=true
        RUN_UI_TEST=true
        BUILD_FOR_TESTING=true
        shift # past argument
        ;;
      --unit-test)
        RUN_UNIT_TEST=true
        BUILD_FOR_TESTING=true # Need build for tests
        shift # past argument
        ;;
      --ui-test)
        RUN_UI_TEST=true
        BUILD_FOR_TESTING=true # Need build for tests
        shift # past argument
        ;;
      --archive-only)
        RUN_ARCHIVE=true
        # Ensure basic checks are also done if only archiving
        # RUN_FORMAT=true
        # RUN_ANALYZE=true
        shift # past argument
        ;;
      --test-without-building)
        TEST_WITHOUT_BUILDING=true
        RUN_PUB_GET=false # Assume deps are fetched
        RUN_BUILD_RUNNER=false # Assume code gen is done
        RUN_FORMAT=false # Skip checks
        RUN_ANALYZE=false # Skip checks
        RUN_BUILD_DEBUG=false # Skip build
        RUN_ARCHIVE=false # Skip archive
        # We still need to know *which* tests to run
        # If no specific test flag is given with this, run all
        if [[ ! "$*" =~ "--unit-test" ]] && [[ ! "$*" =~ "--ui-test" ]]; then
             RUN_UNIT_TEST=true
             RUN_UI_TEST=true
        fi
        shift # past argument
        ;;
      *)    # unknown option
        echo "Unknown option: $1"
        echo "Usage: $0 [--all-tests] [--unit-test] [--ui-test] [--archive-only] [--test-without-building]"
        exit 1
        ;;
    esac
  done
fi

# === Execution Steps ===

# --- Prerequisites ---
if [ "$RUN_PUB_GET" = true ]; then
  step "Running flutter pub get"
  flutter pub get || fail "flutter pub get failed"
fi

if [ "$RUN_BUILD_RUNNER" = true ]; then
  step "Running build_runner"
  flutter pub run build_runner build --delete-conflicting-outputs || fail "build_runner failed"
fi

# --- Code Quality ---
if [ "$RUN_FORMAT" = true ]; then
  step "Checking dart format"
  dart format --set-exit-if-changed . || fail "dart format check failed"
fi

if [ "$RUN_ANALYZE" = true ]; then
  step "Running dart analyze"
  dart analyze || fail "dart analyze failed"
fi

# --- Building ---
# Build only if needed for tests or archive, and not skipping build
if { [ "$BUILD_FOR_TESTING" = true ] || [ "$RUN_ARCHIVE" = true ] || [ "$RUN_BUILD_DEBUG" = true ]; } && [ "$TEST_WITHOUT_BUILDING" = false ]; then
    BUILD_NEEDED=true
else
    BUILD_NEEDED=false
fi

if [ "$BUILD_NEEDED" = true ]; then
    step "Building Debug Versions"
    flutter build apk --debug || fail "flutter build apk --debug failed"

    if [[ "$(uname)" == "Darwin" ]]; then
      step "Building iOS Debug Version (macOS only)"
      # For testing, ensure DerivedData path exists and is used if specified
      # Note: `flutter test` for integration tests might handle its own build.
      # This build is more for `flutter build ios --debug` consistency check.
      mkdir -p "$IOS_DERIVED_DATA_PATH" # Ensure directory exists
      flutter build ios --debug --no-codesign -derivedDataPath="$IOS_DERIVED_DATA_PATH" || fail "flutter build ios --debug failed"
      success "iOS Debug Build completed. DerivedData at: $IOS_DERIVED_DATA_PATH"
    else
      step "Skipping iOS debug build (not on macOS)."
    fi
else
    echo "ℹ️ Skipping Build step as it's not required by the selected options."
fi


# --- Testing ---
TESTS_TO_RUN=false
if [ "$RUN_UNIT_TEST" = true ] || [ "$RUN_UI_TEST" = true ]; then
    TESTS_TO_RUN=true
fi

if [ "$TESTS_TO_RUN" = true ]; then
    step "Running Tests"
    TEST_CMD="flutter test"
    USE_DERIVED_DATA=""

    if [ "$TEST_WITHOUT_BUILDING" = true ] && [[ "$(uname)" == "Darwin" ]] && [ -d "$IOS_DERIVED_DATA_PATH" ]; then
        echo "ℹ️ Attempting to use existing DerivedData for iOS tests: $IOS_DERIVED_DATA_PATH"
        # Note: Flutter test command itself might not directly accept DerivedData path for unit/widget tests.
        # For *integration_test* on devices/simulators, specific build commands might be needed.
        # This part assumes `flutter test` might benefit or that separate integration test runs would use it.
        # If using `integration_test` package, you might need different commands here.
        USE_DERIVED_DATA="true" # Flag indicating we intended to reuse
    fi

    # Select tests to run
    TEST_PATHS=""
    if [ "$RUN_UNIT_TEST" = true ]; then
        TEST_PATHS="$TEST_PATHS test/unit_test" # Adjust path if needed
        echo "Including Unit Tests"
    fi
     if [ "$RUN_UI_TEST" = true ]; then
        TEST_PATHS="$TEST_PATHS test/widget_test" # Assuming UI tests are widget tests or in integration_test
         echo "Including UI/Widget Tests"
         # If UI tests are integration tests requiring a device/simulator:
         # TEST_CMD="flutter test integration_test" # Example
         # Ensure build happened or handle `--test-without-building` appropriately for integration tests
    fi

    if [ -z "$TEST_PATHS" ]; then
        echo "⚠️ No specific tests selected to run."
    else
         # Execute tests
        $TEST_CMD $TEST_PATHS || fail "flutter test execution failed"
        success "Tests completed."
    fi
else
    echo "ℹ️ Skipping Test step as it's not required by the selected options."
fi

# --- Archiving ---
# Run archive only if requested and not skipping build
if [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = false ]; then
  step "Running Archive Builds"
  flutter build appbundle --release || fail "flutter build appbundle failed"
  flutter build apk --release --split-per-abi || fail "flutter build apk --release failed"

  if [[ "$(uname)" == "Darwin" ]]; then
    step "Running flutter build ipa --release (macOS only)"
    flutter build ipa --release --no-codesign || fail "flutter build ipa failed"
  else
    step "Skipping iOS release build (not on macOS)."
  fi
  success "Archive builds completed."
elif [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = true ]; then
     echo "⚠️ Cannot run archive build with --test-without-building flag."
     # fail "Cannot run archive build with --test-without-building flag." # Optionally fail
else
    echo "ℹ️ Skipping Archive step as it's not required by the selected options."
fi


# === Final Success Message ===
ALL_CHECKS_PASSED=true # Assume true initially
# Add checks here if specific steps failed but didn't exit (e.g., optional steps)

if [ "$ALL_CHECKS_PASSED" = true ]; then
    final_message="Local CI script finished successfully with selected options:"
    [ "$RUN_PUB_GET" = true ] && final_message="$final_message pub_get"
    [ "$RUN_BUILD_RUNNER" = true ] && final_message="$final_message build_runner"
    [ "$RUN_FORMAT" = true ] && final_message="$final_message format"
    [ "$RUN_ANALYZE" = true ] && final_message="$final_message analyze"
    [ "$BUILD_NEEDED" = true ] && final_message="$final_message build_debug"
    [ "$RUN_UNIT_TEST" = true ] && final_message="$final_message unit_test"
    [ "$RUN_UI_TEST" = true ] && final_message="$final_message ui_test"
    [ "$RUN_ARCHIVE" = true ] && [ "$TEST_WITHOUT_BUILDING" = false ] && final_message="$final_message archive"
    success "$final_message"
else
    fail "One or more selected steps failed."
fi 