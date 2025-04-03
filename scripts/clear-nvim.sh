#!/usr/bin/bash
# adapted from https://gist.github.com/woosaaahh/bffe3b7db0c6c6401105ab9b56fee280

set -eu

NVIM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"
NVIM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
NVIM_SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
declare -r NVIM_CACHE_DIR NVIM_STATE_DIR NVIM_SHARE_DIR

help() {
  printf '%s' "\
USAGE: $0 <command>...

COMMAND:
  all                Run all commands

  clean-cache        Clean cache directory (${NVIM_CACHE_DIR/$HOME/\~}/)
  clean-state        Clean state directory (${NVIM_STATE_DIR/$HOME/\~}/)
  clean-share        Clean share directory (${NVIM_SHARE_DIR/$HOME/\~}/)

  help               Print this message
"
}

clean-directory() {
  printf '\e[34m%s\e[0m\n' "--> Cleaning $1"
  rm -fr -- "$1"
  mkdir -p -- "$1"
}

clean-cache() {
  clean-directory "$NVIM_CACHE_DIR"
}

clean-state() {
  clean-directory "$NVIM_STATE_DIR"
}

clean-share() {
  clean-directory "$NVIM_SHARE_DIR"
}

all() {
  clean-cache
  clean-state
  clean-share
}

for cmd in "${@:-help}"; do
  "$cmd" >&2
done
