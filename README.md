

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
- Xcode 14.0 or later (available from the Mac App Store)

### Steps

The Xcode project file (`.xcodeproj`) is excluded from the repository via `.gitignore`. You need to recreate it in Xcode before building.

1. **Clone the repository**

   ```bash
   git clone https://github.com/jpomykala/NotchPrompter.git
   cd NotchPrompter
   ```

2. **Create a new Xcode project**

   - Open Xcode and choose **File > New > Project**
   - Select **macOS > App** and click **Next**
   - Set the following options:
     - **Product Name**: `notch-prompter`
     - **Bundle Identifier**: `com.yourname.notch-prompter`
     - **Interface**: SwiftUI
     - **Language**: Swift
   - Save the project **inside** the `NotchPrompter/` folder (so the `.xcodeproj` sits alongside `notch-prompter/`)

3. **Replace generated source files**

   - In Xcode, delete the auto-generated `ContentView.swift` (move to Trash)
   - Drag the following files from the `notch-prompter/` folder into the Xcode project navigator, checking **"Copy items if needed" is OFF** (they are already in place):
     - `AudioMonitor.swift`
     - `NotchPrompterApp.swift`
     - `PrompterView.swift`
     - `PrompterViewModel.swift`
     - `PrompterWindow.swift`
     - `SettingsView.swift`
   - Also add the `Assets.xcassets` folder from `notch-prompter/Assets.xcassets`

4. **Set the deployment target**

   - Select the project in the navigator, then the target
   - Under **General > Minimum Deployments**, set macOS to **13.0**

5. **Add microphone usage description**

   The app requests microphone access for voice activation. Add the required key to `Info.plist`:
   - Select **Info.plist** in the navigator (or go to **Target > Info** tab)
   - Add a new key: `Privacy - Microphone Usage Description`
   - Value: `Used for voice-activated teleprompter control`

6. **Build and run**

   Press **Cmd+R** to build and run the app. The app runs as a menu bar extra with no Dock icon.

   For a release build: **Product > Archive**, then **Distribute App > Copy App** to export the `.app` bundle.

---

## Creating a DMG for Distribution

A DMG (disk image) is the standard way to distribute macOS apps outside the App Store.

### Option A — Using `create-dmg` (recommended)

[`create-dmg`](https://github.com/create-dmg/create-dmg) is a Homebrew-installable tool that produces a polished, styled DMG with a background image and icon layout.

1. **Install create-dmg**

   ```bash
   brew install create-dmg
   ```

2. **Build and export the app**

   In Xcode: **Product > Archive > Distribute App > Copy App**, then export to a folder (e.g. `~/Desktop/build/`).

3. **Create the DMG**

   ```bash
   create-dmg \
     --volname "NotchPrompter" \
     --volicon "notch-prompter/Assets.xcassets/AppIcon.appiconset/mac512.png" \
     --window-pos 200 120 \
     --window-size 600 400 \
     --icon-size 100 \
     --icon "notch-prompter.app" 175 190 \
     --hide-extension "notch-prompter.app" \
     --app-drop-link 425 190 \
     "NotchPrompter-1.2.dmg" \
     "~/Desktop/build/"
   ```

   This creates `NotchPrompter-1.2.dmg` in the current directory.

### Option B — Manual DMG with `hdiutil`

This produces a plain (unstyled) DMG using only built-in macOS tools.

1. **Prepare a staging folder**

   ```bash
   mkdir -p /tmp/dmg-staging
   cp -r ~/Desktop/build/notch-prompter.app /tmp/dmg-staging/
   # Optionally add a symlink to /Applications for drag-install UX:
   ln -s /Applications /tmp/dmg-staging/Applications
   ```

2. **Create and compress the DMG**

   ```bash
   hdiutil create \
     -volname "NotchPrompter" \
     -srcfolder /tmp/dmg-staging \
     -ov \
     -format UDZO \
     NotchPrompter-1.2.dmg
   ```

3. **Clean up**

   ```bash
   rm -rf /tmp/dmg-staging
   ```

### Notarization (optional)

If you have a paid Apple Developer account, notarize the DMG so macOS Gatekeeper accepts it without user override:

```bash
# Submit for notarization
xcrun notarytool submit NotchPrompter-1.2.dmg \
  --apple-id "your@email.com" \
  --team-id "YOURTEAMID" \
  --password "app-specific-password" \
  --wait

# Staple the notarization ticket to the DMG
xcrun stapler staple NotchPrompter-1.2.dmg
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
