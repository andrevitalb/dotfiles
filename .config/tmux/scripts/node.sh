#!/bin/bash
CURRENT_DIR="$1"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

get_full_version() {
    nvm ls "$1" 2>/dev/null | grep -o "v[0-9.]*" | tail -1 | sed 's/^v//'
}

if [ -f "$CURRENT_DIR/.nvmrc" ]; then
    version=$(cat "$CURRENT_DIR/.nvmrc")
    node_version=$(get_full_version "$version")
elif [ -f "$CURRENT_DIR/.node-version" ]; then
    version=$(cat "$CURRENT_DIR/.node-version")
    node_version=$(get_full_version "$version")
else
    node_version=$((nvm current || node -v) 2>/dev/null | sed 's/^v//')
fi

if [ -n "$node_version" ]; then
    echo "$node_version"
else
    echo "Node.js in not found"
fi