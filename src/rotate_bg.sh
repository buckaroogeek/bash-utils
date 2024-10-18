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
### rotate-bg - rotate background images
###
###    By default this is a short description
###    of the script
###
### Usage:
###   rotate-bg.sh               -- this help file
###   rotate-bg.sh -h            -- this help file
###   rotate-bg.sh -y            -- execute using default configuration file
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
    # see https://major.io/p/rotate-gnome-3s-wallpaper-systemd-user-units-timers/
    walls_dir=$HOME/Pictures/Wallpapers
    selection=$(find "$walls_dir" -type f -name "*.jpg" -o -name "*.png" | shuf -n1)
    gsettings set org.gnome.desktop.background picture-uri "file://$selection"
  fi

  echo "** main done **"
}

main "$@"

echo "** script done **"
