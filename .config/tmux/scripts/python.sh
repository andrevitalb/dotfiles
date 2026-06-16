#!/bin/bash
CURRENT_DIR="$1"

# Prefer a version pinned in the local dir (pyenv .python-version),
# otherwise fall back to the active python; show "-" if none resolves.
if [ -f "$CURRENT_DIR/.python-version" ]; then
    python_version=$(head -1 "$CURRENT_DIR/.python-version")
else
    python_version=$( { python -V || python3 -V; } 2>/dev/null | sed 's/Python //' )
fi

if [ -n "$python_version" ]; then
    echo "$python_version"
else
    echo "-"
fi
