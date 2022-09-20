#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

# clean up dnf local repo
# run via sudo

# default dnf local repo configuration file
CFG_NAME=/etc/dnf/plugins/local.conf

###
### repofix - remove older, duplicate content from dnf_local repo.
###
###    By default reads repo path configuration
###    from /etc/dnf/plugins/local.conf
###    ** Run with sudo **
###
### Usage:
###   repofix.sh               -- this help file
###   repofix.sh -h            -- this help file
###   repofix.sh -y            -- execute using default configuration file
###   repofix.sh <repo path>   -- execute on alternate repo
###
### Options:
###  <repo path> Alternate repo path to process
###  -y          Execute script
###  -h          Show this message
###

# See: https://gist.github.com/kovetskiy/a4bb510595b3a6b17bfd1bd9ac8bb4a5
help() {
  sed -rn 's/^### ?//;T;p' "$0"
}

# check for -h or zero arguements
if [[ $# == 0 || "$1" == "-h" ]]; then
  help
  exit 1
fi

# check for -y or <repo path>
if [[ "$1" != "-y" ]]; then
  repodir="$1"
  echo "Processing alternate repo at $repodir"
else
# check if dnf local config file exists
  if [[ ! -f $CFG_NAME ]]; then
    echo "$CFG_NAME does not exist"
    exit 1
  fi

  # source the config file
  # shellcheck disable=SC1094
  # shellcheck source=/etc/dnf/plugins/local.conf
  source <(grep -E '^repodir' "$CFG_NAME" | tr -d ' ')
fi

# shellcheck disable=SC2154
if [[ ! -d "$repodir" ]]; then
  echo "repodir did not parse"
  exit 1
fi

# clean up repo
echo "repodir: $repodir"
dnf repomanage --old  "$repodir"  | xargs -r rm
echo "repomanage done"
createrepo_c --update --unique-md-filenames "$repodir"
echo "createrepo update done"

# refresh dnf cache
dnf makecache --repo=_dnf_local
echo "cache refresh done"

echo "** script done **"
