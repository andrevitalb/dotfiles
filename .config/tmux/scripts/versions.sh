#!/bin/bash
# Emits fully-formatted catppuccin status segments for node / pnpm / python,
# each shown only when the pane's directory (or a parent) is that kind of
# project. No project markers found: no segments at all.
CURRENT_DIR="$1"

[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -r "$HOME/.config/shell/project-env.sh" ] && . "$HOME/.config/shell/project-env.sh"

BG="#1e1e2e" GRAY="#313244" FG="#cdd6f4"
LSEP=" " RSEP=" "

segment() { # color icon text
    printf '#[fg=%s,bg=%s,nobold,nounderscore,noitalics]%s#[fg=%s,bg=%s,nobold,nounderscore,noitalics]%s #[fg=%s,bg=%s] %s#[fg=%s,bg=%s,nobold,nounderscore,noitalics]%s' \
        "$1" "$BG" "$LSEP" "$BG" "$1" "$2" "$FG" "$GRAY" "$3" "$GRAY" "$BG" "$RSEP"
}

find_up() { # dir marker... -> nearest ancestor containing any marker
    local dir="$1" f
    shift
    while [ -n "$dir" ] && [ "$dir" != "/" ]; do
        for f in "$@"; do
            [ -e "$dir/$f" ] && { echo "$dir"; return 0; }
        done
        dir=$(dirname "$dir")
    done
    return 1
}

get_full_node_version() { # expand a spec ("24", "lts/*") to an installed version
    nvm ls "$1" 2>/dev/null | grep -o "v[0-9.]*" | tail -1 | sed 's/^v//'
}

out=""

# --- node (package.json in dir or parent) ---
if node_root=$(find_up "$CURRENT_DIR" package.json); then
    conflict=""
    if node_spec=$(__pe_node_version "$node_root" 2>/dev/null); then
        node_version=$(get_full_node_version "$node_spec")
        [ -z "$node_version" ] && node_version="$node_spec"
        [ -n "$(__pe_node_version "$node_root" 2>&1 1>/dev/null)" ] && conflict="⚠ "
    else
        node_version=$((nvm current || node -v) 2>/dev/null | sed 's/^v//')
    fi
    [ -n "$node_version" ] && out+=$(segment "#60af00" "" "$conflict$node_version")

    # --- pnpm (declared in package.json, or pnpm-lock.yaml present) ---
    pnpm_version=$(__pe_pnpm_version "$node_root" 2>/dev/null)
    if [ -z "$pnpm_version" ] && [ -f "$node_root/pnpm-lock.yaml" ]; then
        pnpm_version=$(pnpm --version 2>/dev/null)
    fi
    [ -n "$pnpm_version" ] && out+=$(segment "#fab387" "󰏗" "$pnpm_version")
fi

# --- python (project markers in dir or parent) ---
if py_root=$(find_up "$CURRENT_DIR" pyproject.toml requirements.txt setup.py .python-version); then
    if [ -f "$py_root/.python-version" ]; then
        py_version=$(head -1 "$py_root/.python-version")
    else
        py_version=$( { python3 -V || python -V; } 2>/dev/null | sed 's/Python //')
    fi
    [ -n "$py_version" ] && out+=$(segment "#89b4fa" "" "$py_version")
fi

echo "$out"
