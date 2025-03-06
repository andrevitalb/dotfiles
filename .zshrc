## ---------- Appearance/Functionality ----------

# ---- P10k ----
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ---- History setup ----
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
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
eval "$(ssh-agent -s)" &>/dev/null

# ---- thefuck ----
eval $(thefuck --alias)
eval $(thefuck --alias fk)

## ---------- Code environments ----------

# ---- NVM ----
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
autoload -U add-zsh-hook

nvm_auto_switch() {
  if [[ -f .nvmrc ]]; then
    nvm use &>/dev/null
  elif [[ -f .node-version ]]; then
    nvm use $(cat .node-version) &>/dev/null
  fi
}

add-zsh-hook chpwd nvm_auto_switch
add-zsh-hook preexec nvm_auto_switch

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

export PATH=$PATH:$HOME/.local/bin:/usr/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$HOME/.avn/bin:$PNPM_HOME

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
# Open any folder in VS Code & exit terminal
codeff() {
	code "$1" && exit
}

# Open any folder in Trae & exit terminal
traef() {
  trae "$1" && exit
}

# General function for simpler updates on editor swapping
codef() {
  traef "$1"
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
alias gdiff="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gba="git branch -a"
alias gadd="git add"
alias ga="git add -p"
alias gcoall="git checkout -- ."
alias gr="git remote"
alias gre="git reset"

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

#---------------------------------------------------------------------------------#

# ---------- Custom project commands ----------


## ---- AV ----
export AV_PATH=$WORK_PATH/av


### -- andrevital.com --
export AV_WEBSITE_PATH=$AV_PATH/andrevital.com

# Navigate to project
alias av="cd $AV_WEBSITE_PATH"
# Open project in code editor
alias av:code="av; codef ."
# Run /frontend
alias av:dev:frontend="av; yarn dev:frontend"
# Run /backend
alias av:dev:backend="av; yarn dev:backend"


### -- Tatem --
export TATEM_PATH=$AV_PATH/tatem

# Navigate to project
alias tatem="cd $TATEM_PATH"
# Open project in code editor
alias tatem:code="tatem; codef."
# Run project
alias tatem:dev="tatem; pnpm dev"


## ---- Metalab ----

### -- Mindlogger --
export MINDLOGGER_PATH=$WORK_PATH/metalab/mindlogger

# Navigate to project
alias ml="cd $MINDLOGGER_PATH"
# Navigate to admin project
alias ml:admin="ml; cd admin"
# Navigate to web project
alias ml:web="ml; cd web"
# Navigate to app project
alias ml:app="ml; cd app"
# Navigate to backend project
alias ml:be="ml; cd backend"
# Navigate to report server project
alias ml:rs="ml; cd report-server"
# Navigate to tests project
alias ml:tests="ml; cd taf"

# Open admin project in code editor
alias ml:admin:code="ml:admin; codef ."
# Open web project in code editor
alias ml:web:code="ml:web; codef ."
# Open app project in code editor
alias ml:app:code="ml:app; codef ."
# Open backend project in code editor
alias ml:be:code="ml:be; codef ."
# Open report server project in code editor
alias ml:rs:code="ml:rs; codef ."
# Open tests project in code editor
alias ml:tests:code="ml:tests; codef ."

# Run admin project
alias ml:admin:start="ml:admin; npm start"
# Run web project
alias ml:web:start="ml:web; yarn dev"
# Run backend project
alias ml:be:start="ml:be; pipenv shell; make run_local; make run"
# Run app project
alias ml:app:start="ml:app; yarn start"
# Run iOS app
alias ml:app:ios="ml:app; yarn ios"

# Run Android app
alias ml:app:android="ml:app; yarn android"

# Steps to run a specific Android emulator
# 1. List existing emulators
# emulator -list-avds
# 2. Run an emulator
# emulator @EMULATOR_NAME
# 3. List emulators to get device ID
# adb devices
# 4. Run app with specified emulator
# ml:app:android --deviceId=DEVICE_ID

# Pull from all git repositories
mlpull() {
    echo -e "\033[36m${bold}MindLogger pull:${normal}" && \
        current_git_pull "$MINDLOGGER_PATH/admin" "Admin" && \
        current_git_pull "$MINDLOGGER_PATH/web" "Web" && \
        current_git_pull "$MINDLOGGER_PATH/app" "App" && \
        current_git_pull "$MINDLOGGER_PATH/backend" "Backend" && \
        current_git_pull "$MINDLOGGER_PATH/report-server" "Report Server" && \
        current_git_pull "$MINDLOGGER_PATH/taf" "Test Automation Framework" && \
        printf "\nAll done!\n" && \
	ml
}
alias ml:pull="mlpull"
