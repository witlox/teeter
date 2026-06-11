# Teeter Tower — Privacy Policy

**Effective date:** 2026-06-11

## Short version

Teeter Tower does not collect, store, transmit, or share any personal data.
There are no accounts, no analytics, no advertising, no third-party SDKs, and
no tracking of any kind. This is by deliberate design — see `DESIGN.md` in the
project repository for the reasoning.

## What the app stores on your device

The only data the app writes is your best banked tower height, kept in
`UserDefaults` (Apple's standard local-key-value store) under the key
`teeter.best`. It never leaves the device. Deleting the app deletes this value.

This use of `UserDefaults` is declared in the app's privacy manifest
(`PrivacyInfo.xcprivacy`) under Apple's required reason **CA92.1** — "access
information from the same app, per documentation."

## What the app does not do

- Does not collect or transmit any data — personal, anonymous, or otherwise.
- Does not include analytics or telemetry of any kind.
- Does not include advertising or any advertising SDK.
- Does not contain trackers.
- Does not require an account, login, email address, or any user identifier.
- Does not access the camera, microphone, contacts, location, calendar,
  photos, or any other system permission.
- Does not contain in-app purchases.
- Does not connect to the network for any feature.

## Children

The app is suitable for all ages (App Store age rating 4+). Because the app
collects no data of any kind, it does not collect data from children either.

## Contact

If you have a question about this policy, email **pim@witlox.io**.

## Changes

If this policy ever changes (for example, if the app is updated to include a
feature that touches user data), the change will be reflected here and in the
updated app's privacy nutrition label on the App Store before the new version
is released.
