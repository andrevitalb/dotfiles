show_versions() {
  # Raw passthrough: the script emits complete pre-styled segments so that
  # node/pnpm/python appear only in matching project directories.
  echo "#($HOME/.config/tmux/scripts/versions.sh #{pane_current_path})"
}
