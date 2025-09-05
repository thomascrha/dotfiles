FROM archlinux:base-devel

# setup user
ARG USER=tcrha
ARG UID=1000
ARG GID=1000

ENV USER=${USER}
ENV UID=${UID}
ENV GID=${GID}

RUN groupadd -g ${GID} ${USER} && \
    useradd -m -u ${UID} -g ${GID} -s /bin/zsh ${USER} && \
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers

# setup locale AU and timezone (Australia/Sydney)
RUN sed -i 's/#en_AU.UTF-8 UTF-8/en_AU.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo "LANG=en_AU.UTF-8" > /etc/locale.conf

ENV TZ=Australia/Sydney
RUN ln -sf /usr/share/zoneinfo/${TZ} /etc/localtime && \
    echo "${TZ}" > /etc/timezone

USER ${USER}
WORKDIR /home/${USER}

# install paru (AUR helper)
# RUN sudo pacman-key --init && \
RUN sudo pacman -Syu --needed --noconfirm \
        git \
        cargo \
        base-devel && \
    git clone https://aur.archlinux.org/paru.git && \
    cd paru && \
    makepkg -si --noconfirm

# install packages
RUN sudo pacman-key --init && \
    sudo pacman -Sy --noconfirm \
        git \
        openssh \
        zsh \
        net-tools \
        stow \
        archlinux-keyring \
        inetutils \
        nodejs

RUN paru -S --noconfirm \
        neovim-nightly-bin

# install dotfiles
RUN git clone https://github.com/thomascrha/dotfiles.git /home/${USER}/dotfiles && \
    cd /home/${USER}/dotfiles && \
    make stow

CMD ["zsh"]
