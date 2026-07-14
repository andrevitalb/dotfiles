# shellcheck shell=sh
# Per-project tool version resolution, shared by the zsh auto-switch hook and
# the tmux status widget. Pure: these functions read declared versions and
# print the chosen one. They never switch anything themselves.
#
# Node precedence:  .nvmrc > .node-version > package.json .volta.node
# pnpm precedence:  package.json .packageManager (pnpm@x) > package.json .volta.pnpm
#
# When a single project declares conflicting versions across sources, a warning
# is printed to stderr (the resolved value still goes to stdout).

# Warn if two or more of the given non-empty values disagree.
__pe_warn_conflict() {
  __pe_kind=$1
  shift
  __pe_seen=""
  __pe_list=""
  __pe_conflict=0
  for __pe_v in "$@"; do
    [ -z "$__pe_v" ] && continue
    __pe_list="${__pe_list:+$__pe_list, }$__pe_v"
    if [ -z "$__pe_seen" ]; then
      __pe_seen=$__pe_v
    elif [ "$__pe_v" != "$__pe_seen" ]; then
      __pe_conflict=1
    fi
  done
  [ "$__pe_conflict" -eq 1 ] && \
    printf 'project-env: conflicting %s versions declared (%s); using the first\n' \
      "$__pe_kind" "$__pe_list" >&2
  return 0
}

# Resolve the intended Node version for a directory.
__pe_node_version() {
  __pe_dir=${1:-$PWD}
  __pe_nvmrc="" __pe_nodever="" __pe_voltanode=""

  [ -f "$__pe_dir/.nvmrc" ] && \
    __pe_nvmrc=$(tr -d ' \t\r\n' < "$__pe_dir/.nvmrc" 2>/dev/null)
  [ -f "$__pe_dir/.node-version" ] && \
    __pe_nodever=$(tr -d ' \t\r\n' < "$__pe_dir/.node-version" 2>/dev/null)
  [ -f "$__pe_dir/package.json" ] && \
    __pe_voltanode=$(jq -r '.volta.node // empty' "$__pe_dir/package.json" 2>/dev/null)

  # normalize a leading v (24.16.0 vs v24.16.0)
  __pe_nvmrc=${__pe_nvmrc#v}
  __pe_nodever=${__pe_nodever#v}
  __pe_voltanode=${__pe_voltanode#v}

  __pe_chosen=""
  for __pe_v in "$__pe_nvmrc" "$__pe_nodever" "$__pe_voltanode"; do
    [ -n "$__pe_v" ] && { __pe_chosen=$__pe_v; break; }
  done
  [ -z "$__pe_chosen" ] && return 1

  __pe_warn_conflict node "$__pe_nvmrc" "$__pe_nodever" "$__pe_voltanode"
  printf '%s\n' "$__pe_chosen"
}

# Resolve the intended pnpm version for a directory.
__pe_pnpm_version() {
  __pe_dir=${1:-$PWD}
  [ -f "$__pe_dir/package.json" ] || return 1

  __pe_pm=$(jq -r '.packageManager // empty' "$__pe_dir/package.json" 2>/dev/null)
  case "$__pe_pm" in
    pnpm@*)
      __pe_pmver=${__pe_pm#pnpm@}
      __pe_pmver=${__pe_pmver%%+*}   # drop the +sha512... integrity suffix
      ;;
    *) __pe_pmver="" ;;
  esac
  __pe_voltapnpm=$(jq -r '.volta.pnpm // empty' "$__pe_dir/package.json" 2>/dev/null)

  __pe_chosen=""
  for __pe_v in "$__pe_pmver" "$__pe_voltapnpm"; do
    [ -n "$__pe_v" ] && { __pe_chosen=$__pe_v; break; }
  done
  [ -z "$__pe_chosen" ] && return 1

  __pe_warn_conflict pnpm "$__pe_pmver" "$__pe_voltapnpm"
  printf '%s\n' "$__pe_chosen"
}
