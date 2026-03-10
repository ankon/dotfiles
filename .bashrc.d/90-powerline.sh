#!/bin/sh

function _update_ps1() {
    PS1="$(powerline-go -error $? -jobs $(jobs -p | wc -l) -condensed -cwd-max-depth 2)"

    # Uncomment the following line to automatically clear errors after showing
    # them once. This not only clears the error for powerline-go, but also for
    # everything else you run in that shell. Don't enable this if you're not
    # sure this is what you want.

    #set "?"
}

if [ "$TERM" != "linux" ] && command -v powerline-go >/dev/null 2>&1; then
    PROMPT_COMMAND="$PROMPT_COMMAND; _update_ps1"
fi

