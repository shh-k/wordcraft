#!/usr/bin/env python3
import re
import json

with open('Cargo.lock', 'r') as f:
    content = f.read()

# Split by [[package]] but stop at [[patch or [patch
package_pattern = r'\[\[package\]\](.*?)(?=\n\[\[package\]\]|\n\[\[patch|\n\[patch\]|$)'
matches = re.findall(package_pattern, content, re.DOTALL)

git_deps = []
for pkg_content in matches:
    if 'source = "git+' in pkg_content:
        name_match = re.search(r'name = "([^"]+)"', pkg_content)
        version_match = re.search(r'version = "([^"]+)"', pkg_content)
        if name_match and version_match:
            name = name_match.group(1)
            version = version_match.group(1)
            git_deps.append(f"{name}-{version}")

# Load existing hashes
with open('hashes.json', 'r') as f:
    all_hashes = json.load(f)

# Filter
filtered = {}
for dep in git_deps:
    if dep in all_hashes:
        filtered[dep] = all_hashes[dep]
    else:
        print(f"WARNING: No hash found for git dependency: {dep}")

with open('hashes-filtered.json', 'w') as f:
    json.dump(filtered, f, indent=2)

print("Filtered hashes written to hashes-filtered.json")
print(json.dumps(filtered, indent=2))