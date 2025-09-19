#!/bin/sh


# Functions for prompt markers, so that shell integrations can jump between them using ctrl+shift+z/x and do other magic.
#
# See https://codeberg.org/dnkl/foot/wiki#user-content-jumping-between-prompts
# See https://learn.microsoft.com/en-us/windows/terminal/tutorials/shell-integration
prompt_marker_FTCS_PROMPT() {
    printf '\e]133;A\e\\'
}
prompt_marker_FTCS_COMMAND_START() {
    printf '\e]133;B\e\\'
}
prompt_marker_FTCS_COMMAND_EXECUTED() {
    printf '\e]133;C\e\\'
}
prompt_marker_FTCS_COMMAND_FINISHED() {
    printf '\e]133;D;%d\e\\' $1
}

# Save the original prompt
export DOTFILES_ORIGINAL_PROMPT_COMMAND=$PROMPT_COMMAND
export DOTFILES_ORIGINAL_PS1=$PS1

# Add the marker
if ! [ "${TERM_PROGRAM}" = "WarpTerminal" ]; then
    # See https://github.com/warpdotdev/Warp/issues/6718
    PROMPT_COMMAND="prompt_marker_FTCS_COMMAND_FINISHED;prompt_marker_FTCS_PROMPT"${PROMPT_COMMAND:+;$PROMPT_COMMAND}
fi
