#!/bin/bash
# Build macOS version locally and upload to GitHub Releases
# Usage: ./scripts/release.sh v1.0.0

set -e

TAG=$1

if [ -z "$TAG" ]; then
  echo "Usage: $0 <tag>"
  echo "Example: $0 v1.0.0"
  exit 1
fi

# Get version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: *//')
echo "Version from pubspec.yaml: $VERSION"

ZIP_NAME="bskylog-${VERSION}-macos.zip"

echo "🔨 Building macOS version..."
flutter build macos --release

echo "📦 Creating $ZIP_NAME..."
cd build/macos/Build/Products/Release
rm -f "../../../../../$ZIP_NAME"
zip -r "../../../../../$ZIP_NAME" *.app
cd ../../../../../

echo "🏷️  Creating and pushing tag $TAG..."
git tag "$TAG"
git push origin "$TAG"

echo ""
echo "✅ Done!"
echo ""
echo "Next steps:"
echo "1. Wait for GitHub Actions to complete the Windows build"
echo "2. Check the draft at https://github.com/hidea/app_bskylog/releases"
echo "3. Upload macOS version with:"
echo ""
echo "   gh release upload $TAG $ZIP_NAME"
echo ""
echo "4. Publish the release"
echo ""
echo "Or manually upload $ZIP_NAME via the Web UI."
