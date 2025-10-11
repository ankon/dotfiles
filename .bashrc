# .bashrc

# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# User specific environment
if ! [[ "$PATH" =~ "$HOME/.local/bin:$HOME/bin:" ]]; then
    PATH="$HOME/.local/bin:$HOME/bin:$PATH"
fi
export PATH

# User specific aliases and functions
# Adjusted from Fedora: sort the scripts
if [ -d ~/.bashrc.d ]; then
    for rc in $(ls -1 ~/.bashrc.d/* | sort -n); do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
export NPM_TOKEN=$(sed -nE "s/\/\/registry.(yarnpkg.com|npmjs.org)\/:_authToken=//p" $HOME/.npmrc)
export GITHUB_TOKEN=$(awk 'BEGIN{FS="="}/[^#]*ghp/{print $2}' < ~/.stratus.toml | tr -d " '")
