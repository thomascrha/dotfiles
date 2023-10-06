export PATH=$HOME/go/bin:/usr/local/bin:$PATH
export ZSH=$HOME/.oh-my-zsh

# OH-MY-ZSH
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
    zsh-autosuggestions
    gitfast
    python
    docker
    kubectl
    sudo
    web-search
    copyfile
    dirhistory
    copybuffer
    history
    jsontools
)

source $ZSH/oh-my-zsh.sh

# POWERLEVEL10K# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
    source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# fuzzy find directories and cd into them
dir() {
    if [ -z "$1" ]; then
        cd $(fd --type d . $HOME | fzf --preview 'tree -C {}')
    else;
        cd $(fd --type d . $1 | fzf --preview 'tree -C {}')
    fi;
}

# fuzzy find files and open them in vim
f() {
    if [ -z "$1" ]; then
        vim $(fd --type f . $HOME | fzf --preview 'batcat --color=always --style=header,grid --line-range :500 {}')
    else;
        vim $(fd --type f . $1 | fzf --preview 'batcat --color=always --style=header,grid --line-range :500 {}')
    fi;
}

# rf()
#     if [ -z "$1" ]; the
#         vim $(echo $(rg --line-number --with-filename . $HOME | fzf --preview 'batcat --color=always --style=header,grid --line-range :500 $(cut -d: -f1 <<< {1}) --highlight-line $(cut -d: -f2 <<< {1})') | cut -d: -f1)
#     else;
#         vim $(echo $(rg --line-number --with-filename . $1 | fzf --preview 'batcat --color=always --style=header,grid --line-range :500 $(cut -d: -f1 <<< {1}) --highlight-line $(cut -d: -f2 <<< {1})') | cut -d: -f1)
#     fi;
# }


# ALIASES
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias publicip='wget http://ipinfo.io/ip -qO -'
alias Source='source $(pwd)/.venv/bin/activate'
alias venv='venv'
alias ll='ls -l'
alias la='ls -lA'
alias l='ls -CF'
alias e="exit"
alias c='clear'
alias reload='source ~/.zshrc'
alias editrc='code ~/.zshrc'

# docker
alias dk='docker container kill $(docker ps -a -q)'
alias dc='docker container rm $(docker ps -a -q)'
alias dr='docker update --restart=no $(docker ps -a -q)'
alias dp="docker image prune --force --filter \"until=`docker images --format '{{.CreatedAt}}' | sed -n '2p' | awk '{print $1;}'`\"" # remove all images except the last 2

alias fr='docker-compose restart fusion-hub-frontend fusion-hub'
alias bat='batcat'

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

alias update='sudo apt update -y'
alias upgrade='sudo apt update -y && sudo apt upgrade -y'
alias mg='sudo mount -t nfs -o vers=4 192.168.10.2:/game ~/game'
alias rw='~/system-files/scripts/re-window.sh'

alias dry='docker run --rm -it -v /var/run/docker.sock:/var/run/docker.sock -e DOCKER_HOST=$DOCKER_HOST moncho/dry'

### tmux
#
#
alias config='tmux new -s config || tmux attach -t config || tmux switch-client -t config'
alias term='tmux new -s term || tmux attach -t term || tmux switch-client -t term'

alias fuck='sudo !-1'
alias memfree="su -c \"echo 3 >'/proc/sys/vm/drop_caches' && swapoff -a && swapon -a && printf '\n%s\n' 'Ram-cache and Swap Cleared'\" root"
alias vim='nvim'

export EDITOR='nvim'
export VISUAL='nvim'
export MANPAGER='nvim +Man!'
export MANWIDTH=999


if [[ $(grep microsoft /proc/version) ]]; then
    # cd $HOME
    # add software to path
    # export PATH=$PATH:$HOME/software/bin

    # alias vpn-start="wsl.exe -d wsl-vpnkit service wsl-vpnkit start"
    alias wit="$HOME/scripts/watch-it.sh $HOME/qbe dev /data/226960/"

    # PORTFORWARDING_HOST=dn18
    # PORTFORWARDING_RUNNING=`ps aux | grep ssh | grep -v grep | grep $PORTFORWARDING_HOST`
    # if [ -z "$PORTFORWARDING_RUNNING" ]; then
    # start port forwarding
    #     ssh -N -L 3128:127.0.0.1:3128 $PORTFORWARDING_HOST >/dev/null 2>&1 &
    #     disown
    # fi
    # alias to add proxy info to pip
    # alias pip="pip --proxy http://localhost:3128"

    WSL_RUNNING=`ps aux | grep vpnkit | grep -v grep`
    if [ -z "$WSL_RUNNING" ]; then
        #start the wsl vpnkit
        wsl.exe -d wsl-vpnkit --cd /app wsl-vpnkit > /dev/null 2>&1 &
    fi

    # DOCKER_FORWARDING=`ps aux | grep ssh | grep -v grep | grep docker`
    # if [ -z "$DOCKER_FORWARDING" ]; then
    #     # start port forwarding
    #     rm -rf /tmp/socket.remote | true
    #     ssh -nNT -L /tmp/socket.remote:/var/run/docker.sock $PORTFORWARDING_HOST >/dev/null 2>&1 &
    #     disown
    # fi

    # export DOCKER_HOST=unix:///tmp/socket.remote

    # Start Docker daemon automatically when logging in if not running.
    DOCKER_RUNNING=`ps aux | grep dockerd | grep -v grep`
    if [ -z "$DOCKER_RUNNING" ]; then
        #sudo dockerd --bip 172.17.0.1/28 > /dev/null 2>&1 &
        sudo service docker start
        # disown
    fi

    # add code to path
    export PATH=$PATH:"/mnt/c/Users/226960/AppData/Local/Programs/Microsoft VS Code/bin:$HOME/.local/bin"

    # fix screen issues with WSL
    # export SCREENDIR=$HOME/.local/run/screen

    # allow poetry to use correct ssl certs
    export REQUESTS_CA_BUNDLE=/etc/ssl/certs/ca-certificates.crt

    # add pip packages to path
    export PATH="/home/tcrha/.local/bin:$PATH"

    export VISUAL=vim
    export EDITOR="$VISUAL"

    export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/ca-certificates.crt
    alias restart-ptt='ssh pm1 ./restart-PTT-pdf-service.sh'
    # alias obsidian='nohup obsidian > /dev/null 2>&1 &'

fi

# Hishtory Config:
export PATH="$PATH:/home/tcrha/.hishtory"
source /home/tcrha/.hishtory/config.zsh

# config with a bare repo
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'

# bun completions
# [ -s "/home/tcrha/.bun/_bun" ] && source "/home/tcrha/.bun/_bun"

# bun
# export BUN_INSTALL="$HOME/.bun"
# export PATH="$BUN_INSTALL/bin:$PATH"
#
# [ -f "/home/tcrha/.ghcup/env" ] && source "/home/tcrha/.ghcup/env" # ghcup-env
#
# export NVM_DIR="$HOME/.nvm"
# [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
# [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
