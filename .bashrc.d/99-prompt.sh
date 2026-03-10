#!/bin/sh

# Mark the end of the prompt and the beginning of the command:
if ! [ "${TERM_PROGRAM}" = "WarpTerminal" ]; then
	# See https://github.com/warpdotdev/Warp/issues/6718
	PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND;}"prompt_marker_FTCS_COMMAND_START"
fi
