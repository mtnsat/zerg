#!/usr/bin/env bash
set -e

#
# Functions
#
function log() {
    if [[ -t 1 ]]; then
        printf "%b>>>%b %b%s%b\n" "\x1b[1m\x1b[32m" "\x1b[0m" \
                                  "\x1b[1m\x1b[37m" "$1" "\x1b[0m"
    else
        printf ">>> %s\n" "$1"
    fi
}

#
# Install git
#
log "installing git"
apt-get -y install git-core

log "Done !"

exit 0