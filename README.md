# dotfiles

Storage for configuration files

This repo contains the required config files for my custom MacOS/Linux setup. This is specifically directed towards using zsh.

## Pre-requisites

Change shell to zsh

```zsh
chsh -s $(which zsh)
```

## Installation

### 1. Install [Homebrew](https://brew.sh/)

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

If Apple Sillicon Mac:

```zsh
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
souce ~/.zprofile
```

### 2. Install [Alacritty](https://alacritty.org/)

```zsh
brew install --cask alacritty
```

### 3. Install required homebrew packages

```zsh
brew install \
  git \
  eza \
  powerlevel10k \
  zsh-syntax-highlighting \
  zsh-autosuggestions \
  zoxide \
  bat \
  fd \
  fzf \
  tmux \
  git-delta \
  tlrc \
  thefuck \
  pnpm
```

### 4. Clone this repo

```zsh
git clone https://github.com/andrevitalb/dotfiles ~/Documents/github/dotfiles
```

### 5. Copy all configs to home directory

```zsh
cp -r ~/Documents/github/dotfiles/. ~/
rm -rf ~/.git ~/.README.md
```

### 6. Load Bat theme

```zsh
bat cache --build
```

### 7. Install nvm

```zsh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts
```

### 8. Install python

[pyenv](https://github.com/pyenv/pyenv) is used to manage python versions.

```zsh
brew install pyenv \
  openssl \
  readline \
  sqlite3 \
  xz \
  zlib \
  tcl-tk@8 \
  libb2
```

Once installed, list available versions with:

```zsh
pyenv install -l
```

At the time of creation, the latest python version is 3.13.2.

```zsh
pyenv install 3.13.2
pyenv global 3.13.2
```

### 9. Install pipenv

```zsh
pip install --user pipenv
```

### 10. Install ruby

[rbenv](https://github.com/rbenv/rbenv) is used to manage ruby versions.

```zsh
brew install rbenv
```

Once installed, list stable versions with the following command:

```zsh
rbenv install -l
```

At the time of creation, the latest ruby version is 3.4.2.

```zsh
rbenv install 3.4.2
rbenv global 3.4.2
```

### 11. tmux configuration

The configured prefix for tmux is <kbd>^</kbd> + <kbd>s</kbd>

```zsh
tmux
```
<!-- TODO: Add theme/catppuccin modules installation -->

To install plugins, press <kbd>^</kbd> + <kbd>s</kbd> + <kbd>I</kbd>.

After this, press <kbd>^</kbd> + <kbd>s</kbd> + <kbd>R</kbd> to reload tmux.

### 12. Install XCode command line tools

These are required for some development tools.

```zsh
xcode-select --install
```

### 13. Install MongoDB

```zsh
brew tap mongodb/brew
brew update
brew install mongodb-community
```

To start mongo service:

```zsh
brew services start mongodb-community
```

### 14. Install skhd

```zsh
brew install koekeishiya/formulae/skhd
skhd --start-service
```
