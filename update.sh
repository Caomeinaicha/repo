#!/bin/bash
# Regenerate the APT index files (Packages, Packages.bz2, Packages.gz) from debs/.
# Run this after adding/removing/replacing any .deb in debs/.
#
# Requires dpkg-scanpackages:  macOS → brew install dpkg   Debian/Ubuntu → apt install dpkg-dev

set -euo pipefail
cd "$(dirname "$0")"

if ! command -v dpkg-scanpackages >/dev/null 2>&1; then
  echo "error: dpkg-scanpackages not found (macOS: brew install dpkg)" >&2
  exit 1
fi

# -m keeps every version of a package instead of only the newest.
dpkg-scanpackages -m debs /dev/null > Packages

rm -f Packages.bz2 Packages.gz
bzip2 -kf Packages
gzip  -nkf Packages   # -n: no timestamp/name in header → byte-identical output for identical input

count=$(grep -c '^Package:' Packages || true)
echo "Repo updated: ${count} package(s) indexed."
