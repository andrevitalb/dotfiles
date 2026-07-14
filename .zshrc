## ---------- Appearance/Functionality ----------

# ---- P10k ----
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- History setup ----
HISTFILE=$HOME/.zsh_history
SAVEHIST=50000
HISTSIZE=50000
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

# ---- Zsh autosuggestions & syntax highlighting ----
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ---- Eza ----
alias ls="eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# ---- Zoxide ----
export _ZO_DOCTOR=0

eval "$(zoxide init zsh)"
alias cd="z"

# ---- FZF ----
eval "$(fzf --zsh)"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

_fzf_compgen_path() {
  fd --hidden --exclude .git --exclude node_modules . "$1"
}

_fzf_compgen_dir() {
  fd --type=d --hidden --exclude .git --exclude node_modules . "$1"
}

source ~/fzf-git.sh/fzf-git.sh

fg="#CBE0F0"
bg="#011628"
bg_highlight="#143652"
purple="#B388FF"
blue="#06BCE4"
cyan="#2CF9ED"

show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"

export FZF_DEFAULT_OPTS="--color=fg:${fg},bg:${bg},hl:${purple},fg+:${fg},bg+:${bg_highlight},hl+:${purple},info:${blue},prompt:${cyan},pointer:${cyan},marker:${cyan},spinner:${cyan},header:${cyan}"
export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"

_fzf_comprun() {
  local command=$1
  shift

  case "$command" in
    cd)           fzf --preview 'eza --tree --color=always {} | head -200' "$@" ;;
    export|unset) fzf --preview "eval 'echo ${}'"         "$@" ;;
    ssh)          fzf --preview 'dig {}'                   "$@" ;;
    *)            fzf --preview "$show_file_or_dir_preview" "$@" ;;
  esac
}

# ---- Bat ----
export BAT_THEME=tokyonight_night
alias cat=bat

# ---- SSH ----
if ! pgrep -u "$USER" ssh-agent > /dev/null; then
  eval "$(ssh-agent -s)" &>/dev/null
fi

# ---- thefuck ----
eval $(thefuck --alias)
eval $(thefuck --alias fk)

# ---- Homebrew ----
alias brewm='
  start=$(date +"%H:%M:%S");
  echo "Updating Homebrew...";
  brew update && \
  echo "Upgrading formulae..." && \
  brew upgrade && \
  echo "Upgrading casks (greedy)..." && \
  brew upgrade --cask --greedy && \
  echo "Cleaning..." && \
  brew cleanup --prune=all && \
  brew autoremove && \
  echo "Checking system..." && \
  brew doctor;
  end=$(date +"%H:%M:%S");
  echo "Done (started at $start, finished at $end)";
'
alias brewl='brew list'
alias brews='brew search'
alias brewi='brew info'

## ---------- Code environments ----------

# ---- NVM ----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
autoload -U add-zsh-hook

# Per-project Node + pnpm auto-switching. The version resolver is shared with
# the tmux status widget (~/.config/shell/project-env.sh). Sources, in order:
#   node: .nvmrc > .node-version > package.json .volta.node
#   pnpm: package.json .packageManager (pnpm@x) > package.json .volta.pnpm
# Conflicting versions within one project print a warning (and the first wins).
[ -r "$HOME/.config/shell/project-env.sh" ] && . "$HOME/.config/shell/project-env.sh"

typeset -g __pe_last_dir=""
project_auto_switch() {
  emulate -L zsh
  # preexec fires before every command; only do the heavy work when the dir changed.
  [[ "$PWD" == "$__pe_last_dir" ]] && return
  __pe_last_dir=$PWD

  local nv pv
  if nv=$(__pe_node_version "$PWD"); then
    nvm use "$nv" &>/dev/null
  fi

  if pv=$(__pe_pnpm_version "$PWD"); then
    # Make sure corepack's pnpm shim is active for the current Node, then pin the version.
    case "$(command -v pnpm)" in
      "${NVM_BIN:-$HOME/.nvm}"/*) ;;
      *) corepack enable pnpm &>/dev/null ;;
    esac
    if [[ "$(pnpm --version 2>/dev/null)" != "$pv" ]]; then
      corepack prepare "pnpm@$pv" --activate &>/dev/null \
        || print -u2 "project-env: could not activate pnpm@$pv"
    fi
  fi
}

add-zsh-hook chpwd project_auto_switch
add-zsh-hook preexec project_auto_switch

# ---- Pyenv ----
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)" &>/dev/null

# ---- rbenv ----
eval "$(rbenv init - zsh)" &>/dev/null

#---------------------------------------------------------------------------------#

## ---------- General custom configuration ----------

# ---- Paths ----
export WORK_PATH=$HOME/Documents/work_stuff
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PNPM_HOME=$HOME/Library/pnpm

export PATH=$PATH:$HOME/.local/bin:/usr/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$HOME/.avn/bin:$PNPM_HOME:$HOME/.codeium/windsurf/bin

alias work="cd $WORK_PATH"

# ---- Output formatting ----
bold=$(tput bold)
normal=$(tput sgr0)

# ---- Generic aliases ----
alias mkdir="mkdir -p"

# Dirs
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ......="cd ../../../../.."

# ---- Stupid ass misspelling clear all the time ----
alias celar="clear"
alias clera="clear"

# ---- General functions ----
alias ws="windsurf"

# Open any folder in VS Code & exit terminal
codef() {
	code "$1" && exit
}

# Open any folder in Trae & exit terminal
traef() {
  trae "$1" && exit
}

# Open any folder in Windsurf & exit terminal
wsf() {
  ws "$1" && exit
}

# General function for simpler updates on editor swapping
idef() {
  wsf "$1"
}

# ---- Alacritty ----
alias aledit="nano ~/.config/alacritty/alacritty.toml"

# ---- Git ----
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpl="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff --color-words HEAD --"
alias gco="git checkout"
alias gb="git branch"
alias gba="git branch -a"
alias gadd="git add"
alias ga="git add -p"
alias gcoall="git checkout -- ."
alias gr="git remote"
alias gre="git reset"

# export GITHUB_TOKEN=<personal access token for npm package installs, fill in locally>

function current_branch() {
	current_branch=$(git branch --show-current)
	echo -e  "\033[36m$current_branch\033[0;39m"
}

function colored_git_pull() {
	git pull 2>&1 | grep -qE "Already up to date\.?"
	if [[ $? -eq 0 ]]; then
			echo -e "\033[32mAlready up to date\033[0;39m"
	else
			git pull
	fi
}

function current_git_pull() {
	cd $1 && echo -e "\nPulling $2 ($(current_branch)):" && colored_git_pull
}

# ---- Docker ----
alias dco="docker compose"
alias dps="docker ps"
alias dpa="docker ps -a"
alias dl="docker ps -l -q"
alias dx="docker exec -it"

dc_up() {
  if [[ $# -eq 0 ]]; then
    echo "Usage: dc_up <service1> <service2> ..."
    return 1
  fi

  for svc in "$@"; do
    # Get this project's container ID (if any)
    local cid
    cid="$(docker compose ps -q "$svc" 2>/dev/null)"

    if [[ -n "$cid" ]]; then
      # If the container exists, check if it's running
      local running
      running="$(docker inspect -f '{{.State.Running}}' "$cid" 2>/dev/null || echo false)"
      if [[ "$running" == "true" ]]; then
        echo "✅ $svc is already running."
      else
        echo "▶️  Starting existing $svc container…"
        docker compose up -d "$svc"
      fi
    else
      echo "▶️  Creating & starting $svc…"
      docker compose up -d "$svc"
    fi
  done
}

# ---- Hermes ----
alias hermes-pull='rsync -av --delete grid:~/vault/hermes/ ~/Documents/obsidian-vault-claude/hermes/'

# ---- Claude Code ----

# Per-folder account switching
# Uses a separate config dir (own credentials/settings/sessions) for the titanx
# work account, selected automatically by the folder claude is launched from.
claude() {
  case "$PWD/" in
    "$HOME/Documents/work_stuff/metalab/titanx/"*)
      CLAUDE_CONFIG_DIR="$HOME/.claude-titanx" command claude "$@" ;;
    *)
      command claude "$@" ;;
  esac
}


#---------------------------------------------------------------------------------#

# ---------- Custom project commands ----------


## ---- AV ----
export AV_PATH=$WORK_PATH/av


### -- andrevital.com --
export AV_WEBSITE_PATH=$AV_PATH/andrevital.com

# Navigate to project
alias av="cd $AV_WEBSITE_PATH"
# Open project in code editor
alias av:code="av; idef ."
# Run /frontend
alias av:dev:fe="av; pnpm dev:frontend"
# Run /backend
alias av:dev:be="av; pnpm dev:backend"


### -- Tatem --
export TATEM_PATH=$AV_PATH/tatem

# Navigate to project
alias tatem="cd $TATEM_PATH"
# Open project in code editor
alias t:code="tatem; idef ."
# Run project
alias t:dev="tatem; pnpm dev"
# Run frontend
alias t:dev:fe="tatem; pnpm dev:frontend"
# Run backend
alias t:dev:be="tatem; pnpm dev:backend"


### -- Meal Tracker --
export MEAL_TRACKER_PATH=$AV_PATH/meal-tracker

# Navigate to project
alias mt="cd $MEAL_TRACKER_PATH"
# Open project in code editor
alias mt:code="mt; idef ."
# Run project
alias mt:dev="mt; pnpm dev"
# Run frontend
alias mt:dev:fe="mt; pnpm dev:frontend"
# Run backend
alias mt:dev:be="mt; pnpm dev:backend"


## ---- Metalab ----
export ML_PATH=$WORK_PATH/metalab


### -- TitanX --
export TX_PATH=$ML_PATH/titanx

# Navigate to project 
alias tx="cd $TX_PATH"

# Navigate to FE app
alias tx:fe="tx; cd fe"
# Navigate to UI library
alias tx:ui="tx; cd ui"

# Run FE project
alias tx:dev:fe="tx:fe; pnpm dev"
# Run UI library (Storybook)
alias tx:dev:ui="tx:ui; pnpm storybook"

# Pull from all git repositories
txpull() {
    echo -e "\033[36m${bold}TitanX pull:${normal}" && \
        current_git_pull "$TX_PATH/fe" "FE" && \
        current_git_pull "$TX_PATH/ui" "UI" && \
        current_git_pull "$TX_PATH/fonts" "Fonts" && \
        printf "\nAll done!\n" && \
	tx
}
alias tx:pull="txpull"


# ### -- KnownDating --
# export KD_PATH=$WORK_PATH/metalab/known/monorepo

# # Navigate to project 
# alias kd="cd $KD_PATH"

# # Navigate to mobile app
# alias kd:mobile="kd; cd apps/mobile"
# # Navigate to API app
# alias kd:api="kd; cd apps/api"

# # Clean prebuild mobile project
# alias kd:mobile:prebuild="kd:mobile; pnpm prebuild:ios:clean"

# # Connect to database
# alias kd:db="docker exec -it postgres psql -U root -d postgres"

# # Run project
# alias kd:dev="kd; pnpm dev"
# # Run mobile project
# alias kd:mobile:dev="kd:mobile; pnpm ios"
# # Run API project
# alias kd:api:dev="kd:api; pnpm dev"

# Pull from all git repositories
# kdpull() {
#     echo -e "\033[36m${bold}KnownDating pull:${normal}" && \
#         current_git_pull "$KD_PATH/mobile" "Mobile" && \
#         current_git_pull "$KD_PATH/mobile/wist-shared" "Shared" && \
#         current_git_pull "$KD_PATH/api" "API" && \
#         current_git_pull "$KD_PATH/web" "Web" && \
#         current_git_pull "$KD_PATH/matching" "Matching" && \
#         printf "\nAll done!\n" && \
# 	kd
# }
# alias kd:pull="kdpull"

# ### -- Lobby --
# export LOBBY_PATH=$WORK_PATH/metalab/lobby

# # Navigate to project 
# alias lobby="cd $LOBBY_PATH"

# # Navigate to fe project
# alias l:fe="lobby; cd fe"
# # Open frontend project in code editor
# alias l:fe:code="l:fe; idef ."
# # Run frontend project
# alias l:fe:start="l:fe; pnpm dev"
# # Run frontend tests
# alias l:fe:test="l:fe; pnpm test"

# # Navigate to backend project
# alias l:be="lobby; cd be"
# # Open backend project in code editor
# alias l:be:code="l:be; idef ."
# # Run backend project
# alias l:be:start="l:be; pnpm generate; pnpm build:packages; cd apps/api; pnpm start:dev"
# # Start required BE docker containers
# alias l:be:dc="dc_up postgres redis"


# # Pull from both git repositories
# lpull() {
#     echo -e "\033[36m${bold}Lobby pull:${normal}" && \
#         current_git_pull "$LOBBY_PATH/fe" "Frontend" && \
#         current_git_pull "$LOBBY_PATH/be" "Backend" && \
#         printf "\nAll done!\n" && \
# 	lobby
# }
# alias l:pull="lpull"


### -- Mindlogger --
# export MINDLOGGER_PATH=$WORK_PATH/metalab/mindlogger

# # Navigate to project
# alias ml="cd $MINDLOGGER_PATH"

# # Navigate to admin project
# alias ml:admin="ml; cd admin"
# # Open admin project in code editor
# alias ml:admin:code="ml:admin; idef ."
# # Run admin project
# alias ml:admin:start="ml:admin; npm start"
# # Run admin tests
# alias ml:admin:test="ml:admin; npm run test"


# # Navigate to web project
# alias ml:web="ml; cd web"
# # Open web project in code editor
# alias ml:web:code="ml:web; idef ."
# # Run web project
# alias ml:web:start="ml:web; yarn dev"


# # Navigate to app project
# alias ml:app="ml; cd app"
# # Open app project in code editor
# alias ml:app:code="ml:app; idef ."
# # Run app project
# alias ml:app:start="ml:app; yarn start"
# # Run iOS app
# alias ml:app:ios="ml:app; yarn ios"
# # Run Android app
# alias ml:app:android="ml:app; yarn android"
# # Steps to run a specific Android emulator
# # 1. List existing emulators
# # emulator -list-avds
# # 2. Run an emulator
# # emulator @EMULATOR_NAME
# # 3. List emulators to get device ID
# # adb devices
# # 4. Run app with specified emulator
# # ml:app:android --deviceId=DEVICE_ID


# # Navigate to backend project
# alias ml:be="ml; cd backend"
# # Open backend project in code editor
# alias ml:be:code="ml:be; idef ."
# # Run backend project
# alias ml:be:start="ml:be; pipenv shell; make run_local; make run"


# # Navigate to report server project
# alias ml:rs="ml; cd report-server"
# # Open report server project in code editor
# alias ml:rs:code="ml:rs; idef ."


# # Navigate to tests project
# alias ml:tests="ml; cd taf"
# # Open tests project in code editor
# alias ml:tests:code="ml:tests; idef ."


# # Pull from all git repositories
# mlpull() {
#     echo -e "\033[36m${bold}MindLogger pull:${normal}" && \
#         current_git_pull "$MINDLOGGER_PATH/admin" "Admin" && \
#         current_git_pull "$MINDLOGGER_PATH/web" "Web" && \
#         current_git_pull "$MINDLOGGER_PATH/app" "App" && \
#         current_git_pull "$MINDLOGGER_PATH/backend" "Backend" && \
#         current_git_pull "$MINDLOGGER_PATH/report-server" "Report Server" && \
#         current_git_pull "$MINDLOGGER_PATH/taf" "Test Automation Framework" && \
#         printf "\nAll done!\n" && \
# 	ml
# }
# alias ml:pull="mlpull"
