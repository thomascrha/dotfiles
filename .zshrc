###########################################################################################
#Zim Setup###################################################################################
#############################################################################################
# use git for plugin management
zstyle ':zim:zmodule' use 'degit'
ZIM_HOME=~/.zim
# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
      https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

# Initialize modules.
source ${ZIM_HOME}/init.zsh

# ------------------------------
# Post-init module configuration
# ------------------------------
# enable vim
bindkey -v

# allow ctrl+arrow to move between words
bindkey "^[[1;5C" forward-word
bindkey "^[[1;5D" backward-word

# Cycle through history based on characters already typed on the line
autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "$terminfo[kcuu1]" up-line-or-beginning-search
bindkey "$terminfo[kcud1]" down-line-or-beginning-search

# SSH Agent
eval $(keychain --eval --quiet id_ed25519)
# ${HOME}/scripts/ssh-agent-setup.sh

bindkey -s '^y' 'yazi\n'

###########################################
#Pokemon########https://github.com/aflaag/pokemon-icat###################################
#########################################################################################
pokemon-icat -g 1

#########################################################################################
#POWERLEVEL10K###########################################################################
#########################################################################################
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
#
# # Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# # Initialization code that may require console input (password prompts, [y/n]
# # confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

#########################################################################################
#Functions###############################################################################
#########################################################################################
# fuzzy find directories and nvim into them
dir() {
    if [ -z "$1" ]; then
        nvim $(fd --type d . $HOME | fzf --preview 'tree -C {}')
    else;
        nvim $(fd --type d . $1 | fzf --preview 'tree -C {}')
    fi;
}

# fuzzy find file names and open them in vim
fir() {
    if [ -z "$1" ]; then
        nvim $(fd --type f . $HOME | fzf --preview 'bat --color=always --style=header,grid --line-range :500 {}')
    else;
        nvim $(fd --type f . $1 | fzf --preview 'bat --color=always --style=header,grid --line-range :500 {}')
    fi;
}

# grep for a string in files and open them in vim
rir() {
    if [ -z "$1" ]; then
        nvim $(echo $(rg --line-number --with-filename . $HOME | fzf --preview 'bat --color=always --style=header,grid --line-range :500 $(cut -d: -f1 <<< {1}) --highlight-line $(cut -d: -f2 <<< {1})') | cut -d: -f1)
    else;
        nvim $(echo $(rg --line-number --with-filename . $1 | fzf --preview 'bat --color=always --style=header,grid --line-range :500 $(cut -d: -f1 <<< {1}) --highlight-line $(cut -d: -f2 <<< {1})') | cut -d: -f1)
    fi;
}

# run script ~/scripts/pass.sh to generate a password and if a argument is passed provide it to the script
pass() {
    if [ -z "$1" ]; then
        $HOME/dotfiles/scripts/pass.sh
    else;
        $HOME/dotfiles/scripts/pass.sh $1
    fi;
}


# upgrade system using dnf or apt determined by the system-files
upgrade() {
    # check if flatpak is installed
    if [ -x "$(command -v flatpak)" ]; then
        flatpak update -y
    fi

    if [[ -f /etc/redhat-release ]]; then
        sudo dnf --refresh upgrade -y

    elif [[ -f /etc/debian_version ]]; then
        sudo apt update -y && sudo apt upgrade -y

    elif [[ -f /etc/arch-release ]]; then
        sudo pacman -Syu --noconfirm
    fi
}

## Windows configs
conf () {
    CONF_ITEM=$1
    if [[ "$CONF_ITEM" == "vscode" ]]; then
        nvim /mnt/c/Users/226960/AppData/Local/Packages/Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe/LocalState/settings.json
    elif [[ "$CONF_ITEM" == "wezterm" ]]; then
        nvim /mnt/c/Users/226960/WezTerm/wezterm.lua
    fi
}


if [[ DEBUG_LOGGER -eq 1 ]]; then
    echo "Starting zshrc"
fi
#########################################################################################
#ALIASES#################################################################################
#########################################################################################
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias publicip='wget http://ipinfo.io/ip -qO -'
alias Source='source $(pwd)/.venv/bin/activate'
alias venv='python3 -m venv .venv && Source'
alias ll='ls -lh'
alias la='ls -lAh'
alias l='ls -CFh'
alias e="exit"
alias c='clear'
alias reload='clear && exec zsh'
alias editrc='nvim ~/.zshrc'

# docker
if [ -x "$(command -v docker)" ]; then
    alias dk='docker rm -f $(docker ps -a -q)'
    alias dc='docker container rm $(docker ps -a -q)'
    alias dr='docker update --restart=no $(docker ps -a -q)'
    alias dp="docker image prune --force --filter \"until=`docker images --format '{{.CreatedAt}}' | sed -n '2p' | awk '{print $1;}'`\"" # remove all images except the last 2
fi

# shorten cd ../../../
alias .1='cd ..'
alias .2='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'

# when creating a directory, create all parent directories
alias mkdir='mkdir -pv'

# confrimations
alias mv='mv -i'
alias cp='cp -i'
alias ln='ln -i'

alias mg='sudo mount -t nfs -o vers=4 192.168.10.2:/game ~/game'

### tmux
alias neovim='tmux new -s neovim || tmux attach -t neovim || tmux switch-client -t neovim'

alias fuck='sudo !-1'
alias memfree="su -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\" root"


if [[ DEBUG_LOGGER -eq 1 ]]; then
    echo "Starting zshrc9"
fi

# Set up go env
if [[ -f /usr/local/go/bin/go ]]; then
    export PATH=$PATH:/usr/local/go/bin
fi


if [[ DEBUG_LOGGER -eq 1 ]]; then
    echo "Starting zshrc 10"
fi

export VISUAL=vim
export EDITOR="$VISUAL"

#########################################################################################
# Wezterm ###############################################################################
#########################################################################################
source $HOME/wezterm.sh

#########################################################################################
#Linux Native#####################################################################################
#########################################################################################
# if [[ $(grep Linux /proc/version) ]]; then
#     alias wezterm='flatpak run org.wezfurlong.wezterm'
# fi

#########################################################################################
#WSL#####################################################################################
#########################################################################################
if [[ $(grep microsoft /proc/version) ]]; then
    export BROWSER=wslview

    # check if wezterm-mux-server is already running using ps aux
    if ! ps aux | grep -v grep |grep wezterm-mux-server > /dev/null; then
        wezterm-mux-server --daemonize
    fi

fi

if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
    source <(fzf --zsh)
fi

export FUNCTIONS_CORE_TOOLS_TELEMETRY_OPTOUT=1

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
