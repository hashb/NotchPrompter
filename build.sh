#!/usr/bin/env bash
# build.sh — Build, package, notarize, and staple NotchPrompter
#
# Usage (unsigned):
#   ./build.sh
#
# Usage (signed + notarized):
#   APPLE_ID="you@example.com" TEAM_ID="ABCDE12345" APP_PASSWORD="xxxx-xxxx-xxxx-xxxx" ./build.sh
#
# Optional env vars:
#   VERSION         — app version string appended to DMG filename (default: 1.2)
#   SCHEME          — Xcode scheme to build (default: notch-prompter)
#   PROJECT         — path to .xcodeproj (default: notch-prompter.xcodeproj)
#   BUILD_DIR       — output directory (default: build)

set -euo pipefail

# ── Configuration ─────────────────────────────────────────────────────────────
VERSION="${VERSION:-1.2}"
SCHEME="${SCHEME:-notch-prompter}"
PROJECT="${PROJECT:-notch-prompter.xcodeproj}"
BUILD_DIR="${BUILD_DIR:-build}"

ARCHIVE_PATH="$BUILD_DIR/NotchPrompter.xcarchive"
EXPORT_PATH="$BUILD_DIR/export"
EXPORT_PLIST="$BUILD_DIR/ExportOptions.plist"
DMG_PATH="$BUILD_DIR/NotchPrompter-$VERSION.dmg"
APP_BUNDLE="$EXPORT_PATH/$SCHEME.app"

# Notarization credentials — leave unset to skip notarization
APPLE_ID="${APPLE_ID:-}"
TEAM_ID="${TEAM_ID:-}"
APP_PASSWORD="${APP_PASSWORD:-}"

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

[[ -f "$PROJECT/project.pbxproj" ]] \
    || error "Xcode project not found at '$PROJECT'. See README for one-time setup instructions."

NOTARIZE=false
if [[ -n "$APPLE_ID" && -n "$TEAM_ID" && -n "$APP_PASSWORD" ]]; then
    NOTARIZE=true
    info "Notarization credentials detected — will sign with Developer ID, notarize, and staple."
else
    info "No notarization credentials — building unsigned (set APPLE_ID, TEAM_ID, APP_PASSWORD to enable)."
fi

# ── Clean ─────────────────────────────────────────────────────────────────────
info "Cleaning previous build artifacts..."
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

# ── Archive ───────────────────────────────────────────────────────────────────
info "Archiving $SCHEME (Release)..."

if $NOTARIZE; then
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        -allowProvisioningUpdates
else
    xcodebuild archive \
        -project "$PROJECT" \
        -scheme "$SCHEME" \
        -configuration Release \
        -archivePath "$ARCHIVE_PATH" \
        CODE_SIGN_IDENTITY="-" \
        CODE_SIGNING_REQUIRED=NO \
        CODE_SIGNING_ALLOWED=NO
fi

# ── Write ExportOptions.plist ─────────────────────────────────────────────────
info "Generating ExportOptions.plist..."

if $NOTARIZE; then
    cat > "$EXPORT_PLIST" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>           <string>developer-id</string>
    <key>signingStyle</key>     <string>automatic</string>
    <key>teamID</key>           <string>${TEAM_ID}</string>
</dict>
</plist>
PLIST
else
    cat > "$EXPORT_PLIST" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>       <string>mac-application</string>
    <key>destination</key>  <string>export</string>
</dict>
</plist>
PLIST
fi

# ── Export ────────────────────────────────────────────────────────────────────
info "Exporting .app bundle..."
xcodebuild -exportArchive \
    -archivePath "$ARCHIVE_PATH" \
    -exportOptionsPlist "$EXPORT_PLIST" \
    -exportPath "$EXPORT_PATH"

[[ -d "$APP_BUNDLE" ]] || error "Export failed — .app not found at '$APP_BUNDLE'"

# ── Create DMG ────────────────────────────────────────────────────────────────
info "Creating DMG..."

# Locate the best available app icon for the DMG volume icon
ICON_PATH="notch-prompter/Assets.xcassets/AppIcon.appiconset"
VOLUME_ICON=""
for size in 512 256 128; do
    candidate=$(find "$ICON_PATH" -name "*${size}*" -name "*.png" 2>/dev/null | head -1)
    if [[ -n "$candidate" ]]; then
        VOLUME_ICON="$candidate"
        break
    fi
done

if command -v create-dmg &>/dev/null; then
    ICON_ARG=()
    [[ -n "$VOLUME_ICON" ]] && ICON_ARG=(--volicon "$VOLUME_ICON")

    create-dmg \
        --volname "NotchPrompter" \
        "${ICON_ARG[@]}" \
        --window-pos 200 120 \
        --window-size 600 400 \
        --icon-size 100 \
        --icon "$SCHEME.app" 175 190 \
        --hide-extension "$SCHEME.app" \
        --app-drop-link 425 190 \
        "$DMG_PATH" \
        "$EXPORT_PATH/"
else
    info "create-dmg not found — using hdiutil (run 'brew install create-dmg' for a styled DMG)"
    STAGING="$BUILD_DIR/dmg-staging"
    mkdir -p "$STAGING"
    cp -r "$APP_BUNDLE" "$STAGING/"
    ln -s /Applications "$STAGING/Applications"

    hdiutil create \
        -volname "NotchPrompter" \
        -srcfolder "$STAGING" \
        -ov \
        -format UDZO \
        "$DMG_PATH"

    rm -rf "$STAGING"
fi

# ── Notarize & Staple ─────────────────────────────────────────────────────────
if $NOTARIZE; then
    info "Submitting DMG for notarization (this may take a few minutes)..."
    xcrun notarytool submit "$DMG_PATH" \
        --apple-id "$APPLE_ID" \
        --team-id "$TEAM_ID" \
        --password "$APP_PASSWORD" \
        --wait

    info "Stapling notarization ticket to DMG..."
    xcrun stapler staple "$DMG_PATH"

    info "Verifying notarization..."
    xcrun stapler validate "$DMG_PATH"
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
ok "Build complete: $DMG_PATH"
if $NOTARIZE; then
    ok "Notarized and stapled — ready for distribution."
else
    ok "Unsigned build — users will need to allow the app in System Settings > Privacy & Security on first launch."
fi
