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
# Install ruby
#
log "updating repository"
sudo apt-get -y update

log "downloading ruby 1.9.3"
cd /tmp
wget --retry-connrefused http://cache.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p484.tar.gz

log "installing dependencies"
sudo apt-get -y install build-essential openssl libreadline6 libreadline6-dev curl git-core zlib1g zlib1g-dev libssl-dev libyaml-dev libsqlite3-dev sqlite3 libxml2-dev libxslt-dev autoconf libc6-dev ncurses-dev automake libtool bison nodejs subversion

log "decompressing ruby"
tar xvfz ruby-1.9.3-p484.tar.gz
cd ruby-1.9.3-p484

log "preparing to build ruby"
./configure --disable-install-doc

log "building ruby"
make
make install

log "Done!"

exit 0