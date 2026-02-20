#!/usr/bin/env bash
# build.sh — Build, package, notarize, and staple NotchPrompter
#
# Signing identity and Developer ID are read automatically from your Keychain
# (no need to pass Apple ID or Team ID on the command line).
#
# Usage:
#   ./build.sh                    # signed DMG (uses Keychain identity)
#   NOTARIZE=true ./build.sh      # signed + notarize + staple
#
# One-time notarization setup (run once, then NOTARIZE=true just works):
#   xcrun notarytool store-credentials "notarytool"
#   # follow the prompts for Apple ID, Team ID, and app-specific password
#
# Optional env vars:
#   VERSION          — version string appended to DMG filename (default: 1.2)
#   SCHEME           — Xcode scheme (default: notch-prompter)
#   PROJECT          — path to .xcodeproj (default: notch-prompter.xcodeproj)
#   BUILD_DIR        — output directory (default: build)
#   NOTARIZE         — set to "true" to notarize and staple (default: false)
#   KEYCHAIN_PROFILE — notarytool keychain profile name (default: notarytool)

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
VERSION="${VERSION:-1.2}"
SCHEME="${SCHEME:-notch-prompter}"
PROJECT="${PROJECT:-notch-prompter.xcodeproj}"
BUILD_DIR="${BUILD_DIR:-build}"
NOTARIZE="${NOTARIZE:-false}"
KEYCHAIN_PROFILE="${KEYCHAIN_PROFILE:-notarytool}"

ARCHIVE_PATH="$BUILD_DIR/NotchPrompter.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
EXPORT_PLIST="$BUILD_DIR/ExportOptions.plist"
APP_BUNDLE="$EXPORT_PATH/$SCHEME.app"
DMG_PATH="$BUILD_DIR/NotchPrompter-$VERSION.dmg"

# ── Helpers ───────────────────────────────────────────────────────────────────
info()  { printf '\033[1;34m▶ %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
error() { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

require_cmd() {
    command -v "$1" &>/dev/null || error "Required command not found: $1  →  $2"
}

# ── Preflight ─────────────────────────────────────────────────────────────────
info "Checking prerequisites..."
require_cmd xcodebuild "Install Xcode from the Mac App Store, then run: sudo xcodebuild -license accept"
require_cmd npx         "Install Node.js from https://nodejs.org"

[[ -f "$PROJECT/project.pbxproj" ]] \
    || error "Xcode project not found at '$PROJECT'. See README for one-time setup instructions."

# ── Clean ─────────────────────────────────────────────────────────────────────
info "Cleaning previous build artifacts..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ── Archive ───────────────────────────────────────────────────────────────────
info "Archiving $SCHEME (Release)..."
xcodebuild archive \
    -project "$PROJECT" \
    -scheme "$SCHEME" \
    -configuration Release \
    -archivePath "$ARCHIVE_PATH" \
    -allowProvisioningUpdates

# ── Export ────────────────────────────────────────────────────────────────────
info "Generating ExportOptions.plist..."
cat > "$EXPORT_PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>       <string>developer-id</string>
    <key>signingStyle</key> <string>automatic</string>
</dict>
</plist>
PLIST

info "Exporting .app bundle..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -exportPath "$EXPORT_PATH"

[[ -d "$APP_BUNDLE" ]] || error "Export failed — .app not found at '$APP_BUNDLE'"

# ── Create DMG ────────────────────────────────────────────────────────────────
# npx create-dmg auto-signs the DMG using the Developer ID from your Keychain
info "Creating DMG with create-dmg..."
npx create-dmg "$APP_BUNDLE" "$BUILD_DIR/" 2>&1 || true
# create-dmg exits non-zero when it can't notarize (which is fine — we do it separately)

# Locate the generated DMG (named "<App> <version>.dmg") and rename it
GENERATED_DMG=$(find "$BUILD_DIR" -maxdepth 1 -name "*.dmg" | head -1)
[[ -n "$GENERATED_DMG" ]] || error "DMG not found in $BUILD_DIR after create-dmg"
mv "$GENERATED_DMG" "$DMG_PATH"
ok "DMG: $DMG_PATH"

# ── Notarize & Staple ─────────────────────────────────────────────────────────
if [[ "$NOTARIZE" == "true" ]]; then
    info "Submitting DMG for notarization (this may take a few minutes)..."
    info "Using keychain profile: $KEYCHAIN_PROFILE"
    xcrun notarytool submit "$DMG_PATH" \
        --keychain-profile "$KEYCHAIN_PROFILE" \
        --wait

    info "Stapling notarization ticket..."
    xcrun stapler staple "$DMG_PATH"

    info "Verifying..."
    xcrun stapler validate "$DMG_PATH"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
ok "Build complete: $DMG_PATH"
if [[ "$NOTARIZE" == "true" ]]; then
    ok "Notarized and stapled — ready for distribution."
else
    ok "Run 'NOTARIZE=true ./build.sh' to notarize (requires one-time keychain setup — see script header)."
fi
