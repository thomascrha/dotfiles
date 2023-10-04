# dotfiles

My dotfiles using a bare git repository as described [here](https://www.atlassian.com/git/tutorials/dotfiles).

## installation

```bash
git init --bare $HOME/.dotfiles
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
dotfiles config --local status.showUntrackedFiles no
```
