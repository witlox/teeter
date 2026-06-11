# Teeter Tower — Privacy Policy

**Effective date:** 2026-06-11

## Short version

Teeter Tower does not collect, store, transmit, or share any personal data
directly. There are no accounts (the app uses no login of its own), no
analytics, no advertising, and no third-party SDKs. The only exception is
optional **Apple Game Center**: if you are signed in to Game Center on your
device, your banked tower height is submitted to Apple as a leaderboard score,
linked to your Game Center identifier (which is itself linked to your Apple
ID). This data is held by Apple, not by us. If you decline Game Center or
aren't signed in, the app runs unchanged and no score leaves the device.

## What the app stores on your device

The only data the app writes is your best banked tower height, kept in
`UserDefaults` (Apple's standard local-key-value store) under the key
`teeter.best`. It never leaves the device. Deleting the app deletes this value.

This use of `UserDefaults` is declared in the app's privacy manifest
(`PrivacyInfo.xcprivacy`) under Apple's required reason **CA92.1** — "access
information from the same app, per documentation."

## What the app does not do

- Does not include analytics or telemetry of any kind.
- Does not include advertising or any advertising SDK.
- Does not contain trackers.
- Does not include any third-party SDKs of any kind.
- Does not require an account or login of its own (Game Center sign-in, if
  used, is handled entirely by iOS).
- Does not access the camera, microphone, contacts, location, calendar,
  photos, or any other system permission.
- Does not contain in-app purchases.
- Does not connect to any network or server other than Apple's Game Center
  (and only when you've opted in by signing into Game Center on your device).

## Game Center (optional)

If you are signed in to Apple's Game Center on your device, the app submits
each banked tower height to the Game Center leaderboard with id
`io.witlox.teeter.tower_height`. Apple links this score to your Game Center
identifier (and therefore to your Apple ID). We do not have, store, or
transmit your Apple ID — Apple handles all of this within their own services
on your device. You can sign out of Game Center at any time via iOS Settings,
and the app will continue to run normally.

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
