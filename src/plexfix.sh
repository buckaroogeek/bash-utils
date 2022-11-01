#!/bin/bash

# basic file system permissions and owner, group for plex

OWNER=bgsmith
GRP=music
LIBRARY=/srv/music

# push current directory
pushd .

# change to music library root
cd ${LIBRARY}
pwd

# change owner and group, recursively
sudo chown -R ${OWNER}:${GRP} *

# fix directory permissions
sudo find ${LIBRARY} -type d -exec chmod 755 {} \;

# fix file permissions
sudo find ${LIBRARY} -type f -exec chmod 644 {} \;

# return to original directory
popd
pwd

