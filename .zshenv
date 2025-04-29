skip_global_compinit=1
# check if doesnt .zshenv.$(hostname) exists
if [[ -f $HOME/.zshenv.$(hostname) ]]; then
    source $HOME/.zshenv.$(hostname)
fi

# XDG shit
XDG_DATA_DIRS=/usr/local/share:/usr/share:/var/lib/flatpak/exports/share/
XDG_DATA_HOME=$HOME/.local/share

source $HOME/.zshenv.secrets
