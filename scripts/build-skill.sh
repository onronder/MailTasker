#!/usr/bin/env bash
# Packages the mailtasker skill as a zip that can be uploaded to Claude (Settings › Capabilities › Skills).
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
out="$root/dist/mailtasker-skill.zip"
mkdir -p "$root/dist"
rm -f "$out"
cd "$root/skills"
zip -qr -X "$out" mailtasker -x '*.DS_Store'
echo "Wrote $out"
unzip -l "$out"
