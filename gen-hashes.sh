#!/usr/bin/env bash
set -euo pipefail

cd /home/sk/suite/wordcraft

echo "Vendoring dependencies (this will download ~1-2GB)..."
cargo vendor --locked --versioned-dirs vendor

echo "Computing hashes (SRI format)..."
first=true
echo "{" > hashes.json
for crate in vendor/*/; do
  name=$(basename "$crate")
  if [ -f "$crate/.cargo-checksum.json" ]; then
    hash=$(nix hash path "$crate" --sri 2>/dev/null)
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> hashes.json
    fi
    echo -n "  \"$name\": \"$hash\"" >> hashes.json
  fi
done
echo "" >> hashes.json
echo "}" >> hashes.json

echo "Done! Hashes written to hashes.json"
cat hashes.json