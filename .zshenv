skip_global_compinit=1
# check if doesnt .zshenv.$(hostname) exists
if [[ -f $HOME/.zshenv.$(hostname) ]]; then
    source $HOME/.zshenv.$(hostname)
fi
source $HOME/.zshenv.secrets
