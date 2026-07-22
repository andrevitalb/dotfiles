show_agent() {
  local index=$1
  local icon="$(get_tmux_option "@catppuccin_agent_icon" "󰚩")"
  local color="$(get_tmux_option "@catppuccin_agent_color" "#cba6f7")"
  local text="$(get_tmux_option "@catppuccin_agent_text" "#($HOME/.config/tmux/scripts/agent.sh)")"

  local module=$( build_status_module "$index" "$icon" "$color" "$text" )

  echo "$module"
}
