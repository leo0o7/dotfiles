export ZSH="$HOME/.oh-my-zsh"

# ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(zsh-autosuggestions zsh-syntax-highlighting git zsh-vi-mode)

# fix cursor in wezterm
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLINKING_BLOCK
ZVM_APPEND_MODE_CURSOR=$ZVM_CURSOR_BLINKING_UNDERLINE

source $ZSH/oh-my-zsh.sh

# editor
export EDITOR='nvim'

# replaced by zsh-vi-mode
# set -o vi

# command history
HISTSIZE=100000
SAVEHIST=100000
HISTFILE=~/.zsh_history
setopt histignoredups
setopt histignorespace
setopt share_history # sync history across tmux panes/windows
setopt hist_verify   # show expanded history before running

export XDG_CONFIG_HOME="$HOME/.config"

# fixes some stuff
export LC_ALL=en_US.UTF-8

# aliases
alias ll='eza --color=always --long --git --no-filesize --icons=always --no-time --no-user --no-permissions'
alias ls='eza --color=always --long --git --icons=always --no-time --no-user'
alias fv='fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim'
alias ff="fd --type f | fzf \
  --preview 'bat --color=always --style=numbers --line-range=:200 {}'"
alias v='nvim'
alias blgtv='~/bin/lgtv'
alias javarun='~/bin/java-runner'
alias mvn-init='~/bin/mvn-init'
alias mvn-run='~/bin/mvn-run'
alias tmuxswitcher='~/bin/tmux-session-switch.sh'
alias latestss='~/bin/get-lastest-ss.sh'
alias pngs2obs='~/bin/pngs-to-obs-link'
alias code2prompt='~/.cargo/bin/code2prompt'
alias md-pdf='~/bin/md-pdf'
alias phpactor='~/bin/phpactor.phar'
alias gaddf='~/bin/gaddf'
alias opencode-ralph-once='~/.opencode-ralph/once.sh'
alias opencode-ralph-afk='~/.opencode-ralph/afk.sh'
alias cd='z'
alias oc='opencode'
function intellij() {
  open -na "IntelliJ IDEA CE.app" --args "$@"
}

# make dbus work from zathura
export DBUS_SESSION_BUS_ADDRESS='unix:path='$DBUS_LAUNCHD_SESSION_BUS_SOCKET

# set up fzf key bindings and fuzzy completion
# must be in zvm_after_init_commands bc zsh vi mode resets commands
zvm_after_init_commands+=('source <(fzf --zsh)')

# zoxide
eval "$(zoxide init zsh)"

# luarocks
LUAROCKS_VERSION="3.11.0_5.1"
eval "$($HOME/.luaver/luarocks/$LUAROCKS_VERSION/bin/luarocks path --bin)"

# imagemagick
export DYLD_FALLBACK_LIBRARY_PATH="$(brew --prefix)/lib:$DYLD_FALLBACK_LIBRARY_PATH"

export PATH="$PATH:/usr/local/texlive/2024basic/bin/universal-darwin"
export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
export PATH="$PATH:$HOME/.luaver/lua/5.1/bin"
export PATH="$HOME/.cargo/bin:$PATH"

# Rosé Pine for fzf
export FZF_DEFAULT_OPTS="
  --height=40%
  --layout=reverse
  --border=rounded
  --info=inline
  --prompt='❯ '
  --pointer='◆'
  --marker='✓'
  --color=fg:#908caa,bg:#232138,hl:#9ccfd8
  --color=fg+:#ebbcba,bg+:#393552,hl+:#9ccfd8
  --color=border:#232138,header:#31748f,gutter:#191724
  --color=spinner:#f6c177,info:#9ccfd8
  --color=pointer:#c4a7e7,marker:#eb6f92,prompt:#908caa"

eval "$(starship init zsh)"
# this must be at the end of the file for sdkman to work!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun completions
[ -s "/Users/leo/.bun/_bun" ] && source "/Users/leo/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
