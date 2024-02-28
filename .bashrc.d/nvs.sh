#!/bin/sh

export NVS_HOME="$HOME/modules/nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

# Force nvs to pick a node version for this shell
# XXX: nvs prints some debug stuff on the console, this breaks scp(1) and other stuff.
nvs use lts >/dev/null
