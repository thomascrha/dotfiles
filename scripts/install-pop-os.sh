#!/bin/bash

HOSTNAME=griffin
hostnamectl set-hostname $HOSTNAME

curl https://pyenv.run | bash

# update everything
sudo apt update
sudo apt upgrade -y
sudo apt dist-upgrade -y
sudo apt autoremove -y
sudo apt autoclean -y
sudo fwupdmgr get-devices
sudo fwupdmgr get-updates
sudo fwupdmgr update


# Install the apt deps
sudo apt install --no-recomends -y \
    git \
    curl \
    wget \
    vim \
    zsh \
    tmux \
    neofetch \
    btop \
    npm \
    python3-pip \
    python3-dev \
    bat \
    ripgrep \
    fd-find \
    fzf \
    xclip \
    gawk

# Install pyenv
curl https://pyenv.run | bash

# install gnome extensions installer
wget -O gnome-shell-extension-installer "https://github.com/brunelli/gnome-shell-extension-installer/raw/master/gnome-shell-extension-installer"
chmod +x gnome-shell-extension-installer
mv gnome-shell-extension-installer /usr/bin/

gnome-shell-extension-installer --yes 517 # caffine
gnome-shell-extension-installer --yes 750 # open weather
gnome-shell-extension-installer --yes 906 # audio selecter
gnome-shell-extension-installer --yes 1040 # random wallpaper
gnome-shell-extension-installer --yes 1319 # gsconnect
gnome-shell-extension-installer --yes 5090 # spacebar
gnome-shell-extension-installer --yes 1287 # unite

# update node and npm
sudo npm install -g npm@latest
sudo npm cache clean -f
sudo npm install -g n
sudo n stable

# then remove the apt version
sudo apt remove --purge nodejs

# gen ssh
ssh-keygen

# Setup dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare https://github.com/thomascrha/dotfiles.git $HOME/.dotfiles
dotfiles checkout

# zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

# tmux
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm

# Install pacstall
sudo bash -c "$(curl -fsSL https://pacstall.dev/q/install)"
pacstall -I wezterm-bin
pacstall -I neovim
pacstall -I teams-for-linux
pacstall -I obsidian-bin

# Install lazygit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit /usr/local/bin

# Install tdrop
mkdir -p $HOME/Software
git clone https://github.com/noctuid/tdrop.git $HOME/Software/tdrop
cd $HOME/Software/tdrop
sudo make install
cd

# Install docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
# add user to docker
sudo systemctl enable docker
sudo systemctl start docker
sudo groupadd docker
sudo usermod -aG docker $USER
