#!/bin/bash
set -e

APP_NAME="Naga"
BUILD_DIR="NagaConfigurator/.build/release"
APP_BUNDLE="$APP_NAME.app"
CONTENTS="$APP_BUNDLE/Contents"
MACOS="$CONTENTS/MacOS"
RESOURCES="$CONTENTS/Resources"

echo "🚀 Building Naga.app..."

# 1. Compile Release
cd NagaConfigurator
swift build -c release
cd ..

# 2. Create Bundle Structure
rm -rf "$APP_BUNDLE"
mkdir -p "$MACOS"
mkdir -p "$RESOURCES"

# 3. Copy Binary
cp "$BUILD_DIR/NagaConfigurator" "$MACOS/$APP_NAME"

# 4. Create Info.plist
cat <<EOF > "$CONTENTS/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>$APP_NAME</string>
    <key>CFBundleIdentifier</key>
    <string>com.ahmedelamin.naga.configurator</string>
    <key>CFBundleName</key>
    <string>$APP_NAME</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleShortVersionString</key>
    <string>2.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>LSMinimumSystemVersion</key>
    <string>13.0</string>
    <key>LSUIElement</key>
    <true/>
</dict>
</plist>
EOF

# 5. Code Sign (Ad-Hoc)
echo "🔏 Signing App..."
codesign --force --deep --sign - "$APP_BUNDLE"

echo "✅ Built $APP_BUNDLE"
