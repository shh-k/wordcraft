#!/usr/bin/env bash
set -euo pipefail

cd /home/sk/suite/wordcraft

# Extract git dependency names from Cargo.lock
# Format: name-version (e.g., craft-fonts-build-0.1.0)
git_deps=()
while IFS= read -r line; do
  if [[ "$line" =~ name\ =\ \"([^\"]+)\" ]]; then
    name="${BASH_REMATCH[1]}"
    # Read next line for version
    read -r ver_line
    if [[ "$ver_line" =~ version\ =\ \"([^\"]+)\" ]]; then
      version="${BASH_REMATCH[1]}"
      git_deps+=("${name}-${version}")
    fi
  fi
done < <(grep -B 1 'source = "git+' Cargo.lock | grep -E 'name =|version =')

# Create a filtered hashes.json with only git dependencies
first=true
echo "{" > hashes-filtered.json
for dep in "${git_deps[@]}"; do
  # Check if this dep exists in hashes.json
  if grep -q "\"$dep\"" hashes.json; then
    hash=$(grep "\"$dep\"" hashes.json | sed 's/.*: "\([^"]*\)".*/\1/')
    if [ "$first" = true ]; then
      first=false
    else
      echo "," >> hashes-filtered.json
    fi
    echo -n "  \"$dep\": \"$hash\"" >> hashes-filtered.json
  else
    echo "WARNING: No hash found for git dependency: $dep" >&2
  fi
done
echo "" >> hashes-filtered.json
echo "}" >> hashes-filtered.json

echo "Filtered hashes written to hashes-filtered.json"
cat hashes-filtered.json