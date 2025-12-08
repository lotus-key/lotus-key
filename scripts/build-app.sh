#!/bin/bash
# Script tạo LotusKey.app bundle từ SPM build

set -e

APP_NAME="LotusKey"
BUILD_DIR=".build/debug"
APP_BUNDLE="${APP_NAME}.app"
CONTENTS_DIR="${APP_BUNDLE}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"
ASSETS_DIR="Sources/LotusKey/Resources/Assets.xcassets"

# Build
echo "🔨 Building..."
swift build

# Tạo app bundle structure
rm -rf "${APP_BUNDLE}"
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Copy executable
cp "${BUILD_DIR}/${APP_NAME}" "${MACOS_DIR}/"

# Copy SPM resource bundle (for localization)
RESOURCE_BUNDLE="${BUILD_DIR}/LotusKey_LotusKey.bundle"
if [ -d "${RESOURCE_BUNDLE}" ]; then
    cp -R "${RESOURCE_BUNDLE}" "${RESOURCES_DIR}/"
    echo "📦 Copied resource bundle"
fi

# Compile Assets.xcassets to generate AppIcon.icns
if [ -d "${ASSETS_DIR}" ]; then
    echo "🎨 Compiling app icon..."
    actool "${ASSETS_DIR}" \
        --compile "${RESOURCES_DIR}" \
        --platform macosx \
        --minimum-deployment-target 14.0 \
        --app-icon AppIcon \
        --output-partial-info-plist /tmp/assetcatalog_generated_info.plist \
        2>/dev/null || echo "⚠️  actool not available, using fallback"

    # Fallback: copy icon PNGs directly if actool failed
    if [ ! -f "${RESOURCES_DIR}/AppIcon.icns" ]; then
        echo "📎 Creating icns from PNGs..."
        ICONSET_DIR="/tmp/AppIcon.iconset"
        rm -rf "${ICONSET_DIR}"
        mkdir -p "${ICONSET_DIR}"
        cp "${ASSETS_DIR}/AppIcon.appiconset/"*.png "${ICONSET_DIR}/" 2>/dev/null || true
        if [ "$(ls -A ${ICONSET_DIR})" ]; then
            iconutil -c icns "${ICONSET_DIR}" -o "${RESOURCES_DIR}/AppIcon.icns" 2>/dev/null || true
        fi
        rm -rf "${ICONSET_DIR}"
    fi
fi

# Tạo Info.plist
cat > "${CONTENTS_DIR}/Info.plist" << PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>${APP_NAME}</string>
    <key>CFBundleIdentifier</key>
    <string>com.lotuskey.app</string>
    <key>CFBundleName</key>
    <string>${APP_NAME}</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
    <key>CFBundleIconName</key>
    <string>AppIcon</string>
    <key>LSUIElement</key>
    <true/>
    <key>NSHighResolutionCapable</key>
    <true/>
</dict>
</plist>
PLIST

echo "✅ Created ${APP_BUNDLE}"
echo ""
echo "To run: open ${APP_BUNDLE}"
echo "To add to Accessibility: Go to System Settings → Privacy & Security → Accessibility → Add ${APP_BUNDLE}"
