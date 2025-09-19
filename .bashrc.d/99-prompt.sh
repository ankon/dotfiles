#!/bin/sh

# Configure a reasonably sane prompt
# - Inject git information
export GITAWAREPROMPT=$DOTFILES_HOME/third-party/git-aware-prompt

if [ -f $GITAWAREPROMPT/main.sh ]; then
	. "${GITAWAREPROMPT}/colors.sh"

	# We only need the side-effects of the defined functions, not the prompt manipulation itself.
	PROMPT_COMMAND_save=$PROMPT_COMMAND
	. "${GITAWAREPROMPT}/prompt.sh"
	PROMPT_COMMAND=$PROMPT_COMMAND_save
fi
PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND;}"find_git_branch;find_git_dirty"

# Mark the end of the prompt and the beginning of the command:
if ! [ "${TERM_PROGRAM}" = "WarpTerminal" ]; then
	# See https://github.com/warpdotdev/Warp/issues/6718
	PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND;}"prompt_marker_FTCS_COMMAND_START"
fi

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