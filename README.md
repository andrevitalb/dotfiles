# dotfiles

Configuration files for André's macOS / Linux setup (zsh + tmux + Alacritty).
Tested on Apple Silicon (zsh 5.9, tmux 3.6b, `/opt/homebrew`).

The repo mirrors `$HOME`: files live at the same relative path they occupy in your
home directory, so installing is a single recursive copy.

## What's tracked

```
.zshrc .zshenv .bash_profile .p10k.zsh   # shell + prompt
.gitconfig                               # git identity, delta, SSH commit signing
.config/alacritty/alacritty.toml         # terminal (imports themes/themes/coolnight.toml)
.config/tmux/                            # tmux.conf, tmux.reset.conf, scripts/ (cal/node/python)
.config/karabiner/karabiner.json         # Karabiner-Elements
.config/bat/themes/                      # tokyonight_night (used by BAT_THEME in .zshrc)
.config/git/ignore                       # global gitignore
.config/htop/htoprc
.config/thefuck/settings.py
fzf-git.sh/fzf-git.sh                    # vendored, sourced by .zshrc
Brewfile                                 # all Homebrew formulae, casks, taps
```

The Alacritty theme collection and `tmux/plugins/` are **not** tracked (see `.gitignore`);
they are restored by cloning the theme repo and by TPM (steps 7 and 6).

## Installation

### 1. Make zsh the login shell

```zsh
chsh -s $(which zsh)
```

### 2. Install [Homebrew](https://brew.sh/)

```zsh
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Apple Silicon only:

```zsh
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
source ~/.zprofile
```

### 3. Clone this repo and copy configs into place

```zsh
git clone https://github.com/andrevitalb/dotfiles ~/Documents/github/dotfiles
cp -r ~/Documents/github/dotfiles/. ~/
rm -rf ~/.git ~/README.md ~/.gitignore ~/Brewfile
chmod +x ~/.config/tmux/scripts/*.sh
```

### 4. Install everything from the Brewfile

```zsh
brew bundle install --file=~/Documents/github/dotfiles/Brewfile
```

Installs the zsh tooling (powerlevel10k, zsh-autosuggestions, zsh-syntax-highlighting),
the CLI deps `.zshrc` relies on (eza, zoxide, fzf, fd, bat, git-delta, thefuck, pnpm),
tmux, version managers (pyenv, rbenv), the Hack Nerd Font cask, and Alacritty's deps.
Some entries are work/optional (mongodb-community, fastlane, applesimutils, stripe,
ngrok, tailscale): trim before running for a minimal setup.

### 5. Build the bat theme cache

```zsh
bat cache --build
```

### 6. tmux plugins (TPM)

```zsh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Start tmux, then press <kbd>^</kbd>+<kbd>s</kbd> <kbd>I</kbd> to install the rest
(tmux-sensible, resurrect, continuum, tmux-thumbs, tmux-fzf, tmux-fzf-url,
catppuccin-tmux, sessionx, floax). Reload with <kbd>^</kbd>+<kbd>s</kbd> <kbd>R</kbd>.
The tmux prefix is <kbd>^</kbd>+<kbd>s</kbd>.

### 7. Alacritty theme collection

Only `coolnight.toml` (the active theme) ships in this repo. Clone the full set:

```zsh
git clone https://github.com/alacritty/alacritty-theme ~/.config/alacritty/themes
```

### 8. nvm (install script, not Homebrew)

```zsh
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash
nvm install --lts
```

`.zshrc` auto-switches node per directory via `.nvmrc` / `.node-version`.

### 9. Python (pyenv) and Ruby (rbenv)

```zsh
brew install pyenv openssl readline sqlite3 xz zlib tcl-tk@8 libb2
pyenv install 3.13.2 && pyenv global 3.13.2
pip install --user pipenv

brew install rbenv
rbenv install 3.4.2 && rbenv global 3.4.2
```

### 10. XCode command line tools

```zsh
xcode-select --install
```

## Notes / gotchas

- **Apple Silicon paths** (`/opt/homebrew`): on Intel the p10k / zsh-* `source` lines in
  `.zshrc` point at `/usr/local/share/...` instead. Adjust if needed.
- **git commit signing**: `.gitconfig` SSH-signs commits with `~/.ssh/id_github.pub`. The
  private key is not in this repo. Generate or restore it, then add the **public** key to
  GitHub under *SSH and signing keys* with key type *Signing key*.
- **`cal.sh`** (tmux meetings widget) needs `ical-buddy` (in the Brewfile) plus macOS
  Calendar calendars named **"Metalab"** and **"Personal"**, with calendar permission granted.
- **Karabiner-Elements**: install the app with `brew install --cask karabiner-elements`,
  then it picks up `~/.config/karabiner/karabiner.json` on launch.
- **`gh` auth** is not stored here. Run `gh auth login` after install.

## No secrets

No credentials are committed. Excluded by design: `~/.config/gh/hosts.yml` (GitHub token),
`~/.ssh/` private keys and `config`, and app dirs like `filezilla`, `stripe`, `raycast`.
