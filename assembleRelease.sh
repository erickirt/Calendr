#!/bin/bash

# Build the Binary
swift build -c release

# Configuration
CONFIG_DIR="Calendr/Config"
BUILD_DIR=".build/arm64-apple-macosx/release"
APP_BUNDLE="$BUILD_DIR/Calendr.app"
CONTENTS="$APP_BUNDLE/Contents"

# Clean up and Create Folders
rm -rf "$APP_BUNDLE"
mkdir -p "$CONTENTS/MacOS"
mkdir -p "$CONTENTS/Resources"
mkdir -p "$CONTENTS/Frameworks"

# Move the Binary
cp "$BUILD_DIR/Calendr" "$CONTENTS/MacOS/"

# Move your existing Info.plist
cp "$CONFIG_DIR/Info.plist" "$CONTENTS/Info.plist"

# Move all SPM-generated Bundles
# These contain your icons, strings, and library resources
cp -R $BUILD_DIR/*.bundle "$CONTENTS/Resources/" 2>/dev/null

# Move Frameworks (like Sentry)
cp -R $BUILD_DIR/*.framework "$CONTENTS/Frameworks/" 2>/dev/null

# --- The "Xcode" Variables --- #
PBXPROJ="Calendr.xcodeproj/project.pbxproj"

get_setting() {
    # Search the file, but ignore any lines that contain 'Test'
    grep "$1 =" "$PBXPROJ" | grep -v "Tests" | head -1 | cut -d'=' -f2 | tr -d '"; '
}

# Extract the values
BUNDLE_ID=$(get_setting "PRODUCT_BUNDLE_IDENTIFIER")
VERSION=$(get_setting "MARKETING_VERSION")
BUILD_NUMBER=$(get_setting "CURRENT_PROJECT_VERSION")
MIN_OS=$(get_setting "MACOSX_DEPLOYMENT_TARGET")

# Path to your packaged plist
PLIST="$CONTENTS/Info.plist"

# Inject using plutil (which IS included in Command Line Tools)
echo "💉 Injecting extracted values: ID=$BUNDLE_ID, Version=$VERSION, Build=$BUILD_NUMBER"

plutil -replace CFBundleIdentifier -string "$BUNDLE_ID" "$PLIST"
plutil -replace CFBundleShortVersionString -string "$VERSION" "$PLIST"
plutil -replace CFBundleVersion -string "$BUILD_NUMBER" "$PLIST"
plutil -replace LSMinimumSystemVersion -string "$MIN_OS" "$PLIST"
plutil -replace CFBundleExecutable -string "Calendr" "$PLIST"
plutil -replace CFBundleName -string "Calendr" "$PLIST"
plutil -replace CFBundlePackageType -string "APPL" "$PLIST"


echo "✅ $APP_BUNDLE assembled successfully!"
