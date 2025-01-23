# TrollStore Enhanced

A jailbroken-like experience for iOS 17.0 and above. Enhanced with new features and exploits.

## Supported Devices/OS
- iOS 17.0 and above
- All devices (arm64e confirmed working)

## New Features

### Enhanced Exploit Chain
TrollStore now includes multiple exploits for increased reliability:

1. CVE-2023-42824 (Primary Exploit)
   - Kernel memory manipulation
   - Root access capabilities
   - iOS 17.0-17.1.1 support

2. CVE-2023-41991 (Backup Exploit)
   - Alternative exploitation method
   - Fallback for device compatibility
   - iOS 17.0-17.2 support

### Real-Time App Modification
- Dynamic environment variable editing
- Custom entitlements injection
- App permission management
- No reboot required for changes

### Advanced Logging System
- Detailed operation logging
- Error tracking and reporting
- Debug information for troubleshooting

## Installation Methods

### Method 1: Direct Installation
1. Download latest IPA from Releases
2. Open in TrollStore
3. Install and trust the app

### Method 2: GitHub Actions Build
1. Fork the repository
2. Enable GitHub Actions
3. Build will automatically create IPA
4. Download from Actions artifacts

## Usage

### App Environment Control
1. Open TrollStore
2. Select an installed app
3. Tap "Modify Environment"
4. Add/Edit variables
5. Changes apply immediately

### Exploit Management
- System automatically selects best exploit
- Manual selection in Advanced Settings
- Status monitoring in Settings

## Building from Source

### Requirements
- Theos
- iOS SDK
- Xcode Command Line Tools

### Build Steps
```bash
make package
```

## Credits
- Original TrollStore by opa334
- CVE-2023-42824 exploit
- CVE-2023-41991 exploit
- Environment modification system

## Troubleshooting
See [install_trollhelper.md](install_trollhelper.md) for detailed installation help.

## License
Available under the same license as the original TrollStore.
