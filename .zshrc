# Zsh customization

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash$

# Pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# AVN
# [[ -s "$HOME/.avn/bin/avn.sh" ]] && source "$HOME/.avn/bin/avn.sh"

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# P10k theme
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# history setup
HISTFILE=$HOME/.zhistory
SAVEHIST=1000
HISTSIZE=999
setopt share_history
setopt hist_expire_dups_first
setopt hist_ignore_dups
setopt hist_verify

bindkey "^[[A" history-search-backward
bindkey "^[[B" history-search-forward

source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

alias ls="eza --color=always --long --no-filesize --icons=always --no-time --no-user --no-permissions"

eval "$(zoxide init zsh)"

alias cd="z"


#---------------------------------------------------------------------------------#

# General custom configuration

export WORK_PATH=$HOME/Documents/work_stuff
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
export ANDROID_HOME=$HOME/Library/Android/sdk
export PNPM_HOME=$HOME/Library/pnpm

export PATH=$PATH:$HOME/.local/bin:/usr/bin:$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$HOME/.avn/bin:$PNPM_HOME

alias work="cd $WORK_PATH"

bold=$(tput bold)
normal=$(tput sgr0)

alias mkdir="mkdir -p"

# Stupid ass misspelling clear all the time
alias celar="clear"
alias clera="clear"

# Open any folder in VS Code & exit terminal
codeff() {
    code "$1" && exit
}

# Open any folder in Trae & exit terminal
traef() {
    trae "$1" && exit
}

# General function for simpler updates on editor choosing
codef() {
    traef "$1"
}

alias aledit="nano ~/.config/alacritty/alacritty.toml"

## Git
alias gcm="git commit -m"
alias gps="git push"
alias gpl="git pull"

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

#---------------------------------------------------------------------------------#

# Custom project commands

## AV
export AV_PATH=$WORK_PATH/av/andrevital.com
# Navigate to project
alias av="cd $AV_PATH"
# Open project in code editor
alias av:code="av && codef ."
# Run /frontend
alias av:dev:frontend="av; yarn dev:frontend"
# Run /backend
alias av:dev:backend="av; yarn dev:backend"



## Metalab


### Mindlogger
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
alias ml:be:start="ml:be; pipenv shell; open --hide --background -a Docker; make run_local; make run"
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
