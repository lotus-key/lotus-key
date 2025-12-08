#!/bin/bash
# Generate app icon PNGs from SVG for macOS
# Requires: Inkscape, ImageMagick, or rsvg-convert

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
SVG_SOURCE="$PROJECT_ROOT/Resources/Icons/lotus-icon.svg"
OUTPUT_DIR="$PROJECT_ROOT/Sources/LotusKey/Resources/Assets.xcassets/AppIcon.appiconset"

# macOS icon sizes (in pixels)
declare -a SIZES=(
    "16:icon_16x16.png"
    "32:icon_16x16@2x.png"
    "32:icon_32x32.png"
    "64:icon_32x32@2x.png"
    "128:icon_128x128.png"
    "256:icon_128x128@2x.png"
    "256:icon_256x256.png"
    "512:icon_256x256@2x.png"
    "512:icon_512x512.png"
    "1024:icon_512x512@2x.png"
)

echo "Generating macOS app icons from SVG..."

# Check for available tools
if command -v rsvg-convert &> /dev/null; then
    CONVERTER="rsvg-convert"
    echo "Using rsvg-convert"
elif command -v inkscape &> /dev/null; then
    CONVERTER="inkscape"
    echo "Using Inkscape"
elif command -v magick &> /dev/null; then
    CONVERTER="magick"
    echo "Using ImageMagick"
else
    echo "Error: No SVG converter found. Please install one of:"
    echo "  - librsvg (brew install librsvg)"
    echo "  - Inkscape (brew install inkscape)"
    echo "  - ImageMagick (brew install imagemagick)"
    exit 1
fi

# Create output directory if it doesn't exist
mkdir -p "$OUTPUT_DIR"

# Generate each icon size
for SIZE_ENTRY in "${SIZES[@]}"; do
    SIZE="${SIZE_ENTRY%%:*}"
    FILENAME="${SIZE_ENTRY#*:}"
    OUTPUT_PATH="$OUTPUT_DIR/$FILENAME"
    
    echo "  Generating $FILENAME (${SIZE}x${SIZE}px)..."
    
    case "$CONVERTER" in
        rsvg-convert)
            rsvg-convert -w "$SIZE" -h "$SIZE" "$SVG_SOURCE" -o "$OUTPUT_PATH"
            ;;
        inkscape)
            inkscape "$SVG_SOURCE" --export-filename="$OUTPUT_PATH" -w "$SIZE" -h "$SIZE" 2>/dev/null
            ;;
        magick)
            magick "$SVG_SOURCE" -resize "${SIZE}x${SIZE}" "$OUTPUT_PATH"
            ;;
    esac
done

echo "Done! Icons generated in: $OUTPUT_DIR"
