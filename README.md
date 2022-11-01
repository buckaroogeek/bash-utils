# bash-utils

A collection of personal bash scripts used on my local workstation.

| Script Name | Purpose | Notes|
| ----------- | ------- | ----- |
| plexfix.sh | Corrects permissions and group for plex music library | The music library for plex on my fedora system is /srv/music. I use the group music for this content. This script walks the directory tree setting group and permissions. I run it after adding new music. |
| template.sh | Template for new bash scripts | Standard starting point for new scripts. Offers simple help file syntax and mandatory flag to actually run. |
| repofix.sh | Clean dnf local repository | The dnf local plugin helps reduce internet bandwidth consumptioon and speed updates on multiple local Fedora machines. This utility eliminates older versions of rpms from the dnf_local repository. |
| template.sh | Template for new bash scripts | Standard starting point for new scripts. Offers simple help file syntax and mandatory flag to actually run. |
