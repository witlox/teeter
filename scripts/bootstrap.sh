#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
if ! command -v xcodegen >/dev/null 2>&1; then
  echo "XcodeGen not found. Install with: brew install xcodegen"
  exit 1
fi
# Seed the local xcconfig (your Apple Developer team id) if missing. It's
# gitignored — never committed — so a fresh clone needs this once.
if [ ! -f Configuration/Local.xcconfig ]; then
  cp Configuration/Local.xcconfig.example Configuration/Local.xcconfig
  echo "Created Configuration/Local.xcconfig from the example."
  echo "Edit it and set DEVELOPMENT_TEAM, then re-run this script."
fi
xcodegen generate
echo "Generated Teeter.xcodeproj — opening…"
open Teeter.xcodeproj
