#!/bin/sh

# Configure a reasonably sane prompt
# - Inject git information
export GITAWAREPROMPT=$DOTFILES_HOME/third-party/git-aware-prompt

if [ -f $GITAWAREPROMPT/main.sh ]; then
    . "${GITAWAREPROMPT}/colors.sh"
    . "${GITAWAREPROMPT}/prompt.sh"
fi
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND;}"find_git_branch;find_git_dirty;"

PS1="\$git_user_warning[\u@\h \W\$git_branch\$git_dirty]\$ "
DOTFILES_PS1="$PS1"
case $TERM in
xterm-*|rxvt-*|foot|foot-*)
	# Export the working directory into the window title
	DOTFILES_PS1="$DOTFILES_PS1\[\033]0;🖵 \W\007\]"
	;;
*)
	;;
esac
export DOTFILES_PS1
PS1=$DOTFILES_PS1
export PS1

set +x