# Release Procedure

## Overview

- **Windows**: Automatically built via GitHub Actions
- **macOS**: Built locally, then manually uploaded

## Release Steps

### 1. Build macOS version locally

```bash
# Get version from pubspec.yaml (e.g., 0.1.2+30)
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: *//')

flutter build macos --release

cd build/macos/Build/Products/Release
zip -r "../../../../../bskylog-${VERSION}-macos.zip" *.app
cd ../../../../../
```

### 2. Create and push a tag

```bash
git tag v1.0.0
git push origin v1.0.0
```

This triggers GitHub Actions to automatically build the Windows version.

### 3. Wait for Actions to complete

Check the build status at [Actions](https://github.com/hidea/app_bskylog/actions).

Once completed, a draft release will be created at [Releases](https://github.com/hidea/app_bskylog/releases) with `bskylog-{version}-windows.zip` attached.

### 4. Upload macOS version

#### Using GitHub CLI

```bash
gh release upload v1.0.0 bskylog-{version}-macos.zip
```

#### Using Web UI

1. Go to [Releases](https://github.com/hidea/app_bskylog/releases)
2. Click "Edit" on the draft release
3. Drag and drop `bskylog-{version}-macos.zip` to upload

### 5. Publish the release

1. Review and edit release notes
2. Click "Publish release"

---

## Using the Script

A script is available to automate steps 1-2:

```bash
./scripts/release.sh v1.0.0
```

Then proceed with steps 3-5.

---

## Test Build for Development (Windows)

To test the Windows version on a develop branch:

1. Go to [Actions](https://github.com/hidea/app_bskylog/actions)
2. Select "Build Windows" from the left sidebar
3. Click "Run workflow" button
4. Select the branch (e.g., develop)
5. Choose Build type (debug / release)
6. Click "Run workflow"

After the build completes:

1. Click on the completed workflow run
2. Scroll down to the "Artifacts" section at the bottom of the page
3. Download the zip file (retained for 7 days)

---

## Required Tools

### GitHub CLI (Optional)

To upload the macOS version via CLI:

```bash
brew install gh
gh auth login
```
