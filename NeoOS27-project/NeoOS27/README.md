# NeoOS 27

A Theos jailbreak tweak prototype for iOS 15, targeting legacy Home-button iPhones (6s/6s Plus/7/7 Plus/8).

> Unofficial community project. "iOS 27" is a visual theme target, not an Apple OS port. This prototype creates a Dynamic-Island-style overlay and swipe-up navigation gesture; it cannot add hardware or guarantee compatibility with every jailbreak.

## Targets

- **Rootless**: `make package ROOTLESS=1` (installs under `/var/jb`)
- **Rootful**: `make package ROOTLESS=0` (traditional filesystem layout)

Theos, an iOS 15 SDK, and a compatible jailbreak build environment are required. The package builds are not signed by Apple.

## Features in this starter

- Floating pill overlay with tap-to-expand demo panel
- Configurable visibility, glass opacity, and swipe-up navigation
- Swipe from the bottom edge to trigger Home; long swipe can show the app switcher where the OS accepts the selector
- Preference plist at `/var/mobile/Library/Preferences/com.neoos27.tweak.plist`
- Separate rootless/rootful package metadata through Theos' `THEOS_PACKAGE_SCHEME`

## Build

1. Install Theos on macOS/Linux and configure an iOS SDK.
2. Put this folder at `$THEOS/projects/NeoOS27` or clone your repository.
3. Build rootless:
   ```sh
   make clean package ROOTLESS=1
   ```
4. Build rootful:
   ```sh
   make clean package ROOTLESS=0
   ```
5. Install the generated `.deb` with your jailbreak's package manager, then respring.

The build host must have Theos and the relevant SDK; this archive does not include an SDK or a prebuilt `.deb`.

## Configure

Edit `/var/mobile/Library/Preferences/com.neoos27.tweak.plist` using a plist editor, then respring:

- `Enabled` (boolean, default true)
- `IslandEnabled` (boolean, default true)
- `GestureEnabled` (boolean, default true)
- `GlassOpacity` (real, 0.82, range 0.35–1.0)
- `ShowDemoStatus` (boolean, default true)

Example:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
  <key>Enabled</key><true/>
  <key>IslandEnabled</key><true/>
  <key>GestureEnabled</key><true/>
  <key>GlassOpacity</key><real>0.82</real>
  <key>ShowDemoStatus</key><true/>
</dict></plist>
```

## Important limitations

- This is an early prototype, not a finished replica of iOS 27.
- The pill is an overlay, not a cutout-aware system component. Older iPhones have no front camera cutout to conceal.
- App-switcher activation uses a private SpringBoard selector and may not work on every iOS 15 build. The Home gesture has a safer fallback.
- The actual Home button and Touch ID are not disabled; this avoids making the device difficult to recover or unlock.
- Liquid Glass is approximated with UIKit blur and translucency. Native system-wide appearance requires additional per-app integrations.
- Test on a spare device and keep a way to enter Safe Mode. A bad SpringBoard hook can cause respring loops.
