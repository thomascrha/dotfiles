# add local bin path for pokemon-icat
export PATH=$PATH:$HOME/.local/bin
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

###########################################
#Pokemon########https://github.com/aflaag/pokemon-icat###################################
#########################################################################################
pokemon-icat -g 1

#########################################################################################
#Exports#################################################################################
#########################################################################################
export PATH=$HOME/go/bin:/usr/local/bin:$PATH
export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='nvim +Man!'
export MANWIDTH=999

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
alias ll='ls -l'
alias la='ls -lA'
alias l='ls -CF'
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
alias vim='nvim'


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
    # cd $HOME
    # add software to path
    # export PATH=$PATH:$HOME/software/bin

    # alias vpn-start="wsl.exe -d wsl-vpnkit service wsl-vpnkit start"

    # PORTFORWARDING_RUNNING=`ps aux | grep ssh | grep -v grep | grep $PORTFORWARDING_HOST`
    # if [ -z "$PORTFORWARDING_RUNNING" ]; then
    # start port forwarding
    #     ssh -N -L 3128:127.0.0.1:3128 $PORTFORWARDING_HOST >/dev/null 2>&1 &
    #     disown
    # fi
    # alias to add proxy info to pip
    # alias pip="pip --proxy http://localhost:3128"

    # alias docker-compose="docker compose"
    #
    # WSL_RUNNING=`ps aux | grep vpnkit | grep -v grep`
    # if [ -z "$WSL_RUNNING" ]; then
    #     # start the wsl vpnkit
    #     wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit > /dev/null 2>&1 &
    # fi
    # alias docker-compose="docker compose"

    # WSL_RUNNING=`ps aux | grep vpnkit | grep -v grep`
    # if [ -z "$WSL_RUNNING" ]; then
    #     # start the wsl vpnkit
    #     wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit > /dev/null 2>&1 &
    # fi

    # DOCKER_FORWARDING=`ps aux | grep ssh | grep -v grep | grep docker`
    # if [ -z "$DOCKER_FORWARDING" ]; then
    #     # start port forwarding
    #     rm -rf /tmp/socket.remote | true
    #     ssh -nNT -L /tmp/socket.remote:/var/run/docker.sock $PORTFORWARDING_HOST >/dev/null 2>&1 &
    #     disown
    # fi

    # export DOCKER_HOST=unix:///tmp/socket.remote

    # Start Docker daemon automatically when logging in if not running.
    # DOCKER_RUNNING=`ps aux | grep dockerd | grep -v grep`
    # if [ -z "$DOCKER_RUNNING" ]; then
    #     # sudo dockerd --bip 172.17.0.1/28 > /dev/null 2>&1 &
    #     # disown
    #     sudo service docker start
    # fi

    # add code to path

    # fix screen issues with WSL
    # export SCREENDIR=$HOME/.local/run/screen

    # allow poetry to use correct ssl certs
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

    # add pip packages to path
    export PATH="/home/tcrha/.local/bin:$PATH"

    export VISUAL=vim
    export EDITOR="$VISUAL"

    export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt

    alias kill-vpnkit="sudo kill -9 $(ps aux | grep vpnkit | grep -v grep | awk '{print $2}')"

fi

if [[ -f "$HOME/.fzf.zsh" ]]; then
    source "$HOME/.fzf.zsh"
    source <(fzf --zsh)
fi

