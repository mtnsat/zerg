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
# Install java and jmeter
#
log "installing java"
apt-get update --fix-missing
apt-get -y install openjdk-7-jre

log "installing jmeter"
apt-get -y install jmeter

log "Done !"
exit 0
 
