

<img width="128" height="128" alt="notch-promptern-macOS-Default-128x128@2x" src="https://github.com/user-attachments/assets/0eff155d-c2f6-497b-80ce-6eab223935e4" />

# NotchPrompter for macOS

A **very basic**, always-on-top floating text prompter for macOS.
Perfect for quick videos, or keeping important text visible while you work.

[Install NotchPrompter 1.2](https://github.com/jpomykala/NotchPrompter/releases/download/1.2/notch-prompter.zip)


## Features
- Always on top
- Voice activation
- Minimalist design
- Lightweight
- Pause on hover
- Customizable speed and size

## Screenshot
<!-- <img width="1512" height="720" alt="SCR-20251206-qhya" src="https://github.com/user-attachments/assets/a85e4573-85a3-4296-b454-a41a7b62cae9" /> -->
<img width="1016" height="796" alt="SCR-20251207-pqrp" src="https://github.com/user-attachments/assets/99670434-e295-45c4-ba7b-a261d6faf943" />


## How to install?

Head to [Releases](https://github.com/jpomykala/NotchPrompter/releases) and download the zip file. Unzip it and move notch-prompter.app into your Applications folder.

> Important: [App is not notarized because it requires a paid Apple License](https://apple.stackexchange.com/questions/388554/is-a-paid-apple-developer-account-required-for-notarizing-macos-apps). So on the first run you will have to go to **Settings -> Privacy & Security** scroll down and allow to open the app.

## Building from Source

### Prerequisites

- macOS 13.0 or later
- Xcode 14.0 or later — install from the Mac App Store, then accept the license:
  ```bash
  sudo xcodebuild -license accept
  ```

### One-time project setup

The Xcode project file (`.xcodeproj`) is excluded from the repository. You need to create it once before you can use `xcodebuild` from the command line.

1. Clone the repository:

   ```bash
   git clone https://github.com/jpomykala/NotchPrompter.git
   cd NotchPrompter
   ```

2. Open Xcode, choose **File > New > Project > macOS > App**, and configure:
   - **Product Name**: `notch-prompter`
   - **Bundle Identifier**: `com.yourname.notch-prompter`
   - **Interface**: SwiftUI · **Language**: Swift
   - Save the project inside the `NotchPrompter/` folder

3. In the Xcode project navigator, delete the generated `ContentView.swift` (move to Trash), then drag in the files from `notch-prompter/` with **"Copy items if needed" OFF**:
   `AudioMonitor.swift`, `NotchPrompterApp.swift`, `PrompterView.swift`, `PrompterViewModel.swift`, `PrompterWindow.swift`, `SettingsView.swift`, and the `Assets.xcassets` folder.

4. Set the deployment target: **Target > General > Minimum Deployments > macOS 13.0**

5. Add the microphone privacy key: **Target > Info tab**, add key `Privacy - Microphone Usage Description` with value `Used for voice-activated teleprompter control`.

### Build from the command line

After the one-time setup above, all builds can be done entirely in the terminal.

**Debug build (run locally):**

```bash
xcodebuild \
  -project notch-prompter.xcodeproj \
  -scheme notch-prompter \
  -configuration Debug \
  -derivedDataPath build/DerivedData
```

**Release archive:**

```bash
xcodebuild archive \
  -project notch-prompter.xcodeproj \
  -scheme notch-prompter \
  -configuration Release \
  -archivePath build/NotchPrompter.xcarchive
```

**Export `.app` from archive (unsigned — no Apple Developer account needed):**

```bash
# Write an export options plist
cat > /tmp/ExportOptions.plist <<'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key><string>mac-application</string>
    <key>destination</key><string>export</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
  -archivePath build/NotchPrompter.xcarchive \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -exportPath build/export
```

The exported app will be at `build/export/notch-prompter.app`.

---

## Creating a DMG for Distribution

### Automated (recommended) — use `build.sh`

The included [`build.sh`](build.sh) script handles the full pipeline:
archive → export → DMG → notarize → staple.

Signing identity is read automatically from your Keychain — no credentials on the command line.

```bash
# Signed DMG (uses Developer ID from Keychain)
./build.sh

# Signed + notarized + stapled
NOTARIZE=true ./build.sh
```

**One-time notarization setup** (only needed once — credentials are stored securely in Keychain):

```bash
xcrun notarytool store-credentials "notarytool"
# prompts for Apple ID, Team ID, and app-specific password
```

Set `VERSION` to override the default (`1.2`):

```bash
VERSION=1.3 ./build.sh
```

The final DMG is written to `build/NotchPrompter-<version>.dmg`.

### Manual — `npx create-dmg`

[`create-dmg`](https://github.com/sindresorhus/create-dmg) (npm) auto-signs the DMG using the Developer ID already in your Keychain — no credentials needed:

```bash
# After exporting the .app to build/export/
npx create-dmg build/export/notch-prompter.app build/
```

### Manual — `hdiutil` (no extra tools needed)

```bash
mkdir -p /tmp/dmg-staging
cp -r build/export/notch-prompter.app /tmp/dmg-staging/
ln -s /Applications /tmp/dmg-staging/Applications

hdiutil create \
  -volname "NotchPrompter" \
  -srcfolder /tmp/dmg-staging \
  -ov -format UDZO \
  build/NotchPrompter-1.2.dmg

rm -rf /tmp/dmg-staging
```

### Notarization (manual)

Store your credentials once in Keychain:

```bash
xcrun notarytool store-credentials "notarytool"
# prompts for Apple ID, Team ID, and app-specific password
```

Then submit and staple:

```bash
xcrun notarytool submit build/NotchPrompter-1.2.dmg \
  --keychain-profile "notarytool" \
  --wait

xcrun stapler staple build/NotchPrompter-1.2.dmg
```

---

## Contributing
All contributions are welcome! Whether you're fixing bugs, improving the UI, or adding new features, your help is appreciated.

## Donating

If you enjoy using NotchPrompter and find it useful, you can support the project. Your donation will **[help me cover the cost of an Apple Developer License](https://github.com/sponsors/jpomykala)**, which is required to publish the app on the Mac App Store. Every contribution, big or small, brings me closer to making NotchPrompter available for everyone directly from the App Store.

## Roadmap
- [ ] Customizable position
- [ ] Option to choose font
- [ ] Option to change line height
- [ ] Support multi-monitor setups

## License
This project is open-source and available under the MIT License.

## Questions or Ideas?
Open an issue or reach out!

## Star History

[![Star History Chart](https://api.star-history.com/svg?repos=jpomykala/NotchPrompter&type=date&legend=top-left)](https://www.star-history.com/#jpomykala/NotchPrompter&type=date&legend=top-left)
