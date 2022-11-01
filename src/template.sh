#!/usr/bin/env bash

# see https://sharats.me/posts/shell-script-best-practices/ for source
# and inspiration
#
set -o errexit
set -o nounset
set -o pipefail

if [[ "${TRACE-0}" == "1" ]]; then
    set -o xtrace
fi

###
### template - bash script template.
###
###    By default this is a short description
###    of the script
###
### Usage:
###   template.sh               -- this help file
###   template.sh -h            -- this help file
###   template.sh -y            -- execute using default configuration file
###   template.sh <option>      -- execute with options
###
### Options:
###  <option>    Some option to process
###  -y          Execute script
###  -h          Show this message
###

# See: https://gist.github.com/kovetskiy/a4bb510595b3a6b17bfd1bd9ac8bb4a5
help() {
  sed -rn 's/^### ?//;T;p' "$0"
}

# check for -h or zero arguements
# if [[ $# == 0 || "$1" == "-h" ]]; then
if [[ $# == 0 || "${1-}" =~ ^-*h(elp)?$ ]]; then
  help
  exit 1
fi

# main
main () {
  # check for -y
  if [[ "${1-}" != "-y" ]]; then
    echo "Execute flag not set. Process option and proceed"
    # option="$1"
  else
    echo "Proceed with defaults"
  fi

  echo "** main done **"
}

main "$@"

echo "** script done **"
