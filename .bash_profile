#!/bin/sh

# ~/.local/bin is before ~/bin, as the former is "more standard"
# See https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html for a discussion
# NOTE: No user-owned directories should be before the system-owned ones, to prevent security issues
export PATH=$PATH:$HOME/.local/bin:$HOME/bin

_me=${BASH_SOURCE[0]}
if [ -L "${_me}" ]; then
	_me=$(readlink "${_me}")
fi
DOTFILES_HOME=`cd $(dirname ${_me:-$0}) >/dev/null 2>&1; echo $PWD`

# Make gpg 1.4.x find the gnupg-agent 2.1.x
# See https://bugzilla.redhat.com/show_bug.cgi?id=1221234#c5
# See https://bugs.gnupg.org/gnupg/issue1986
# XXX: Left here for historic reasons; no longer using GPG 1.4.x
#export GPG_AGENT_INFO=${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent::1
#export GPG_TTY=`tty`

# Configure a reasonably sane prompt
# - Inject git information
export GITAWAREPROMPT=$DOTFILES_HOME/third-party/git-aware-prompt
if [ -f $GITAWAREPROMPT/main.sh ]; then
	. $GITAWAREPROMPT/main.sh
	PS1="[\u@\h \W\$git_branch\$git_dirty]\$ "
else
	PS1='[\u@\h \W]\$ '
fi

# - Add the kubectl context
find_kubectl_context() {
	# XXX: Would be nice to also show the current namespace
	kubectl_context=`kubectl config current-context 2>/dev/null`
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

# Configure the prompt but also expose the previous settings
export DOTFILES_ORIGINAL_PROMPT_COMMAND=$PROMPT_COMMAND
export DOTFILES_PROMPT_COMMAND="find_kubectl_context; $PROMPT_COMMAND"
PROMPT_COMMAND=$DOTFILES_PROMPT_COMMAND

export DOTFILES_ORIGINAL_PS1=$PS1
DOTFILES_PS1="\$kubectl_context_formatted$PS1"
case $TERM in
xterm-*|rxvt-*)
	# Export the working directory into the window title
	DOTFILES_PS1="$DOTFILES_PS1\[\033]0;(Terminal) \W\007\]"
	;;
*)
	;;
esac
export DOTFILES_PS1
PS1=$DOTFILES_PS1

# Prefer vim, if available.
_vim=`which vim`
if [ -n "${_vim}" ] && [ -x "${_vim}" ]; then
	alias vi=${_vim}
fi

# Prefer xterm-color when using ssh(1), as most remotes don't speak rxvt-unicode-...
# See https://serverfault.com/questions/302159/is-it-possible-to-change-value-of-term-when-calling-ssh
case "$TERM" in
rxvt-*)
	alias ssh='TERM=xterm-color ssh'
	;;
esac

export NVS_HOME="$DOTFILES_HOME/third-party/nvs"
[ -s "$NVS_HOME/nvs.sh" ] && . "$NVS_HOME/nvs.sh"

GIT_COMPLETION="$DOTFILES_HOME/third-party/git/contrib/completion/git-completion.bash"
test -f "$GIT_COMPLETION" && . "$GIT_COMPLETION"

[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
