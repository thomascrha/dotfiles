#!/usr/bin/bash
# adapted from https://gist.github.com/woosaaahh/bffe3b7db0c6c6401105ab9b56fee280


help() {
  printf '%s' "\
USAGE: $0 [OPTIONS] <command>...

OPTIONS:
    --app-name, -a <name>   Set the Neovim app name (default: nvim)
    --help, -h              Print this message

COMMAND:
    all                     Run all commands
    runtime                 Cleasn runtime directories (cache, state, share)

    cache                   Clean cache directory
    state                   Clean state directory
    share                   Clean share directory
    config                  Clean configuration directory

    help                    Print this message
"
}

if [ $# -gt 0 ]; then
  while [[ "$1" =~ ^- && ! "$1" == "--" ]]; do
    case "$1" in
    --app-name | -a)
      shift
      NVIM_APP_NAME="$1"
      ;;
    --help | -h)
      help
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 1
      ;;
    esac
    shift
  done
  if [[ "$1" == '--' ]]; then
    shift
  fi
fi

NVIM_APP_NAME="${NVIM_APP_NAME:-nvim}"
NVIM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/$NVIM_APP_NAME"
NVIM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/$NVIM_APP_NAME"
NVIM_SHARE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/$NVIM_APP_NAME"
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$NVIM_APP_NAME"

clean-directory() {
  if [[ ! -d "$1" ]]; then
    printf '\e[33m%s\e[0m\n' "Directory $1 does not exist, skipping."
    return
  fi
  printf '\e[34m%s\e[0m\n' "--> Cleaning $1"
  rm -fr "$1"
}

config() {
  clean-directory "$NVIM_CONFIG_DIR"
}

cache() {
  clean-directory "$NVIM_CACHE_DIR"
}

state() {
  clean-directory "$NVIM_STATE_DIR"
}

share() {
  clean-directory "$NVIM_SHARE_DIR"
}

runtime() {
  cache
  state
  share
}

all() {
  cache
  state
  share
  config
}

for cmd in "${@:-help}"; do
  "$cmd" >&2
done
# vim: set ft=sh ts=2 sts=2 sw=2 et:
