# dotfiles

My dotfiles using a bare git repository as described [here](https://www.atlassian.com/git/tutorials/dotfiles).

## usage 

#### initialise
```bash
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
```

#### restore
```bash
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
git clone --bare git@github.com:thomascrha/dotfiles.git $HOME/.dotfiles
dotfiles checkout
```
NOTE: you may need to move some files - here's a hand snippet for doing that
```bash
mkdir -p .config-backup && \
    config checkout 2>&1 | egrep "\s+\." | awk {'print $1'} | \
    xargs -I{} mv {} .config-backup/{}
dotfiles config --local status.showUntrackedFiles no
```
