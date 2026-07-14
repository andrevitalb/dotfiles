#!/bin/bash
CURRENT_DIR="$1"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -r "$HOME/.config/shell/project-env.sh" ] && . "$HOME/.config/shell/project-env.sh"

# Expand a version spec (e.g. "24", "lts/*", "24.16.0") to a full installed version.
get_full_version() {
    nvm ls "$1" 2>/dev/null | grep -o "v[0-9.]*" | tail -1 | sed 's/^v//'
}

conflict=""

# --- Node version ---
if node_spec=$(__pe_node_version "$CURRENT_DIR" 2>/dev/null); then
    node_version=$(get_full_version "$node_spec")
    [ -z "$node_version" ] && node_version="$node_spec"
    [ -n "$(__pe_node_version "$CURRENT_DIR" 2>&1 1>/dev/null)" ] && conflict="⚠ "
else
    node_version=$((nvm current || node -v) 2>/dev/null | sed 's/^v//')
fi

# --- pnpm version (the version the project declares) ---
pnpm_version=$(__pe_pnpm_version "$CURRENT_DIR" 2>/dev/null)
[ -n "$(__pe_pnpm_version "$CURRENT_DIR" 2>&1 1>/dev/null)" ] && conflict="⚠ "

if [ -n "$node_version" ]; then
    out="$node_version"
else
    out="-"
fi
[ -n "$pnpm_version" ] && out="$out | pnpm $pnpm_version"

echo "$conflict$out"
