#!/usr/bin/env bash
# Check content, then build the whole site the way the live site is built.
# Usage: scripts/check.sh            (exit 0 = safe to publish)
set -euo pipefail
cd "$(dirname "$0")/.."
export LANG=C.UTF-8 JEKYLL_ENV=production
# Some machines (cloud sessions) keep gem commands like `jekyll` off the PATH.
export PATH="$(ruby -e 'print Gem.bindir'):$PATH"

echo "== Checking changed posts and pages"
python3 scripts/check_content.py

echo "== Building the site"
bundle check >/dev/null 2>&1 || bundle install
log=$(mktemp)
if ! bundle exec jekyll build 2>&1 | tee "$log"; then
  echo "BUILD FAILED (see the messages above)"; exit 1
fi
if grep -Eiq "error|liquid exception" "$log"; then
  echo "BUILD PRINTED ERRORS (see above)"; exit 1
fi
echo "OK: the site builds."
