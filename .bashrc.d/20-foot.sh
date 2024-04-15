#!/bin/sh

# Add prompt markers, so that foot can jump between them using ctrl+shift+z/x
#
# See https://codeberg.org/dnkl/foot/wiki#user-content-jumping-between-prompts
prompt_marker() {
    printf '\e]133;A\e\\'
}

# Emit OSC-7 to report the current working directory.
#
# This allows foot (and presumably other terminals) to know the current working directory, and
# then for instance spawn new terminals in it (ctrl+shift+n).
osc7_cwd() {
    local strlen=${#PWD}
    local encoded=""
    local pos c o
    for (( pos=0; pos<strlen; pos++ )); do
        c=${PWD:$pos:1}
        case "$c" in
            [-/:_.!\'\(\)~[:alnum:]] ) o="${c}" ;;
            * ) printf -v o '%%%02X' "'${c}" ;;
        esac
        encoded+="${o}"
    done
    printf '\e]7;file://%s%s\e\\' "${HOSTNAME}" "${encoded}"
}

PROMPT_COMMAND=${PROMPT_COMMAND:+$PROMPT_COMMAND;}"prompt_marker;osc7_cwd"
