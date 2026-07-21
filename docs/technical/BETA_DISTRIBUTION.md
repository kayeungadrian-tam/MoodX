# MoodX macOS Beta Distribution

- **Last reviewed:** 2026-07-21
- **Current app version:** 0.4.0 (build 6)
- **Recommended first-beta channel:** Developer ID signing, Apple notarization,
  and direct ZIP distribution
- **Status:** Procedure documented; distribution credentials and notarized
  artifact are not yet configured

## Recommendation

Distribute the first MoodX beta outside the Mac App Store as a notarized app.
This preserves the current local architecture, avoids making TestFlight and App
Sandbox migration prerequisites for user research, and gives testers a normal
Gatekeeper-verified launch experience.

Use TestFlight later if centralized invitations, automatic 90-day expiry,
crash/feedback collection, or an eventual Mac App Store release justify the
additional packaging and sandbox work.

## Current readiness

| Item | Current state | Required action |
|---|---|---|
| App bundle | Built by `scripts/build_macos_app.sh` | Retain the reproducible release build |
| Code signature | Ad-hoc; no Team ID | Sign with **Developer ID Application** |
| Hardened Runtime | Not enabled | Sign the app and embedded executable with runtime hardening |
| Microphone entitlement | Not present | Add `com.apple.security.device.audio-input` to the app signature |
| Notarization | Not configured | Submit with `notarytool`, then staple the ticket |
| CPU architecture | App and bundled `whisper-cli` are arm64-only | Limit the first beta to Apple silicon or build and test universal binaries |
| Minimum OS | macOS 14 | State this in the invitation and release notes |
| BlackHole | External prerequisite | Ask testers/IT to install official BlackHole 2ch separately |
| Update channel | None | Send each beta as a new versioned download |

The current development Mac has Xcode and `notarytool`, but does not currently
have a Developer ID Application identity. Apple Developer Program membership
and certificate installation are therefore the first external prerequisites.

## One-time Apple setup

1. Enroll the individual or organization in the Apple Developer Program.
2. In Xcode **Settings → Accounts → Manage Certificates**, create or download a
   **Developer ID Application** certificate.
3. Create notarization credentials. Prefer a keychain profile so secrets do not
   appear in scripts or repository files:

   ```zsh
   xcrun notarytool store-credentials "MoodX-Notary" \
     --apple-id "APPLE_ACCOUNT_EMAIL" \
     --team-id "TEAM_ID" \
     --password "APP_SPECIFIC_PASSWORD"
   ```

4. Never commit the certificate, private key, app-specific password, API key,
   or keychain export.

## Required entitlement

Create a release-only entitlements plist containing:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.device.audio-input</key>
    <true/>
</dict>
</plist>
```

This is a Hardened Runtime resource-access entitlement, not an App Sandbox
decision. The existing `NSMicrophoneUsageDescription` must remain in
`Info.plist` so macOS can present the consent prompt.

## Build, sign, notarize, and package

The release script should eventually automate this flow. Until then, perform it
from the repository root with the real Developer ID identity substituted:

```zsh
zsh scripts/build_macos_app.sh

moodx_app="dist/MoodX Mixer.app"
moodx_tool="$moodx_app/Contents/Resources/LocalSTT/whisper-cli"
moodx_entitlements="path/to/MoodXDistribution.entitlements"
moodx_identity="Developer ID Application: ORGANIZATION (TEAM_ID)"
moodx_submission="dist/MoodX-Mixer-0.4.0-notary.zip"
moodx_release="dist/MoodX-Mixer-0.4.0-beta.zip"

codesign --force --timestamp --options runtime \
  --identifier "com.moodx.mixer.whisper-cli" \
  --sign "$moodx_identity" "$moodx_tool"

codesign --force --timestamp --options runtime \
  --entitlements "$moodx_entitlements" \
  --sign "$moodx_identity" "$moodx_app"

codesign --verify --deep --strict --verbose=2 "$moodx_app"
ditto -c -k --keepParent "$moodx_app" "$moodx_submission"

xcrun notarytool submit "$moodx_submission" \
  --keychain-profile "MoodX-Notary" \
  --wait

xcrun stapler staple "$moodx_app"
xcrun stapler validate "$moodx_app"
spctl --assess --type execute --verbose=2 "$moodx_app"

ditto -c -k --keepParent "$moodx_app" "$moodx_release"
```

Sign nested executable code before signing the outer app. Do not use
`codesign --deep` to create the signature; use `--deep` only when verifying it.
If the optional local STT runtime is omitted, skip the nested `whisper-cli`
signing command and clearly mark transcription unavailable in that beta.

Every distributed build must receive a unique, increasing `CFBundleVersion`.
Use a versioned filename and preserve the exact released artifact and its
SHA-256 digest in a private release record.

## Tester package

Send testers:

1. the notarized MoodX ZIP through an access-controlled company download,
   GitHub Release, or equivalent HTTPS host;
2. the official BlackHole 2ch installation link rather than a repackaged
   driver;
3. supported hardware/OS: Apple silicon and macOS 14+ for the current build;
4. a short setup checklist: install BlackHole, unzip/copy MoodX to Applications,
   allow microphone access, choose BlackHole 2ch as the Teams microphone, and
   keep Teams speakers on physical headphones;
5. the beta's privacy statement and consent expectations;
6. known limitations and rollback/uninstall steps; and
7. one feedback route plus instructions for sharing the relevant
   `MoodXMixer-*.ips` crash report when a crash occurs.

Do not bundle or redistribute BlackHole with MoodX until its licensing and
enterprise installation terms are explicitly reviewed. Directing testers to
the official installer keeps that dependency and its updates attributable to
its publisher.

## Release gate

Before inviting external testers, verify on a clean or representative Mac:

- Gatekeeper accepts the downloaded artifact without a bypass;
- microphone consent succeeds under the hardened signature;
- BlackHole is discovered and removed cleanly from the private aggregate after
  Stop session and app exit;
- Teams receives both speech and every pad while Teams playback remains on
  physical headphones;
- local STT can launch the signed embedded helper and delete temporary files;
- custom pad bookmarks survive relaunch;
- the timer, checkpoint, and Quiet Think flow works; and
- uninstall instructions remove MoodX preferences and explain that BlackHole is
  a separate dependency.

## TestFlight alternative

TestFlight for Mac supports internal and external beta groups, feedback, crash
information, and 90-day build expiry. For MoodX it is a second-phase channel,
not a packaging switch. It requires an App Store Connect app record, an
App-Store-distribution-signed upload, and App Sandbox for Mac App Store
distribution. Before choosing it, spike and document:

- Core Audio device enumeration and private aggregate creation in the sandbox;
- execution of the embedded `whisper-cli` helper and local Metal model access;
- security-scoped custom audio files;
- upload/archive production from the current Swift Package layout; and
- whether BlackHole-dependent behavior is acceptable during beta review.

If any core audio behavior is incompatible with App Sandbox, keep direct
Developer ID distribution as the supported channel rather than weakening the
product to fit TestFlight.

## Official references

- [Apple: Signing software with Developer ID](https://developer.apple.com/developer-id/)
- [Apple: Creating distribution-signed code for macOS](https://developer.apple.com/documentation/xcode/creating-distribution-signed-code-for-the-mac)
- [Apple: Notarizing macOS software](https://developer.apple.com/documentation/security/notarizing-macos-software-before-distribution)
- [Apple: Customizing the notarization workflow](https://developer.apple.com/documentation/security/customizing-the-notarization-workflow)
- [Apple: Hardened Runtime](https://developer.apple.com/documentation/xcode/configuring-the-hardened-runtime/)
- [Apple: TestFlight overview](https://developer.apple.com/help/app-store-connect/test-a-beta-version/testflight-overview/)
- [Apple: App Sandbox](https://developer.apple.com/documentation/security/app-sandbox)
- [BlackHole: official installation guide](https://github.com/ExistentialAudio/BlackHole/wiki/Installation)
