#!/bin/bash

# basic file system permissions and owner, group for plex

OWNER=plex
GRP=plex
LIBRARY=/srv/music

# push current directory
pushd .

# change to music library root
cd ${LIBRARY}
pwd

# change owner and group, recursively
sudo chown -R ${OWNER}:${GRP} *

# fix directory permissions
sudo find ${LIBRARY} -type d -exec chmod 775 {} \;

# fix file permissions
sudo find ${LIBRARY} -type f -exec chmod 664 {} \;

# return to original directory
popd
pwd

