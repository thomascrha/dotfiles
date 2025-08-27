skip_global_compinit=1
# check if doesnt .zshenv.$(hostname) exists
if [[ -f $HOME/.zshenv.$(hostname) ]]; then
    source $HOME/.zshenv.$(hostname)
fi

# add local bin path for pokemon-icat
PATH=$HOME/.local/bin:$HOME/go/bin:/usr/local/bin:/mnt/c/Users/226960/WezTerm:$PATH

# neovim
EDITOR='nvim'
VISUAL='nvim'
MANPAGER='nvim +Man!'
MANWIDTH=999

# XDG shit
XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/flatpak/exports/share/
XDG_DATA_HOME=$HOME/.local/share

source $HOME/.zshenv.secrets

if [[ -f $HOME/.cargo/env ]]; then
    . "$HOME/.cargo/env"
fi
