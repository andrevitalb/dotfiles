#!/usr/bin/env bash
# Catppuccin status-module logic for agent-manager (phase-0).
# Shows Claude sessions that need you (⚠), any near their context limit (🔥), and
# sessions that just finished work (✓ <session>, transient), reading the state dirs
# the attention/context hooks maintain.
#
# Emits fg-only tmux styling so the pill background stays catppuccin's gray;
# colors are the mocha palette. Wired via @catppuccin_agent_text in tmux.conf.
set -uo pipefail

BASE="${XDG_CACHE_HOME:-$HOME/.cache}/agent-manager"
WAIT="$BASE/waiting"
NEAR="$BASE/nearlimit"
DONE="$BASE/done"
RENDER="$HOME/Documents/work_stuff/av/agent-manager/prototypes/phase-0/render-labels.sh"
DONE_TTL="${AGENT_MANAGER_DONE_TTL_SECS:-120}"

# catppuccin mocha palette
FG="#cdd6f4"; YELLOW="#f9e2af"; PEACH="#fab387"; GREEN="#a6e3a1"

# Labels are session-named (session:N when a session has >1 agent); the helper
# resolves them live and drops orphaned panes. done/ entries fade after DONE_TTL.
waiting=""
near=""
done_lbls=""
if [ -x "$RENDER" ]; then
  waiting="$("$RENDER" "$WAIT" 2>/dev/null)"
  near="$("$RENDER" "$NEAR" withpct 2>/dev/null)"
  done_lbls="$("$RENDER" "$DONE" "" "$DONE_TTL" 2>/dev/null)"
fi

out=""
[ -n "$waiting" ] && out="#[fg=$YELLOW,bold]⚠ $waiting#[fg=$FG,nobold]"
[ -n "$near" ] && out="${out:+$out }#[fg=$PEACH]🔥 $near#[fg=$FG]"
[ -n "$done_lbls" ] && out="${out:+$out }#[fg=$GREEN]✓ $done_lbls#[fg=$FG]"
[ -z "$out" ] && out="#[fg=$GREEN]✓#[fg=$FG]"

printf '%s' "$out"
