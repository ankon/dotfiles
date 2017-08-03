#!/bin/sh

# Make gpg 1.4.x find the gnupg-agent 2.1.x
# See https://bugzilla.redhat.com/show_bug.cgi?id=1221234#c5
# See https://bugs.gnupg.org/gnupg/issue1986
export GPG_AGENT_INFO=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent::1
export GPG_TTY=`tty`

# Configure a reasonably sane prompt
# - Inject git information
if [ -f $HOME/modules/git-aware-prompt/prompt.sh ]; then
	. $HOME/modules/git-aware-prompt/prompt.sh
	PS1="[\u@\h \W\$git_branch\$git_dirty]\$ "
else
	PS1='[\u@\h \W]\$ '
fi

# - Add the kubectl context
find_kubectl_context() {
	# XXX: Would be nice to also show the current namespace
	kubectl_context=`kubectl config current-context`
	if [ -z "${kubectl_context}" ]; then
		kubectl_context_formatted=
	else
		if [ "${kubectl_context}" = "minikube" ]; then
			kubectl_context_formatted="[${kubectl_context}] "
		else
			kubectl_context_formatted="[\033\[31m${kubectl_context}\033\[0m] "
		fi	
	fi
}
PROMPT_COMMAND="find_kubectl_context; $PROMPT_COMMAND"
PS1="\$kubectl_context_formatted$PS1"

case $TERM in
xterm-*|rxvt-*)
	# Export the working directory into the window title
	PS1="$PS1\[\033]0;(Terminal) \W\007\]"
	;;
*)
	;;
esac
export PS1

# Prefer vim, if available.
_vim=`which vim`
if [ -n "${_vim}" ] && [ -x "${_vim}" ]; then
	alias vi=${_vim}
fi

