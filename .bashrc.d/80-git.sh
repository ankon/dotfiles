#!/bin/sh

# Configure auto-completions
GIT_COMPLETION="$DOTFILES_HOME/third-party/git/contrib/completion/git-completion.bash"
test -f "$GIT_COMPLETION" && . "$GIT_COMPLETION"

