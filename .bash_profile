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

# Save the original prompt
export DOTFILES_ORIGINAL_PROMPT_COMMAND=$PROMPT_COMMAND
export DOTFILES_ORIGINAL_PS1=$PS1

# Configure a reasonably sane prompt
# - Inject git information
export GITAWAREPROMPT=$DOTFILES_HOME/third-party/git-aware-prompt
if [ -f $GITAWAREPROMPT/main.sh ]; then
	. $GITAWAREPROMPT/main.sh
fi

# Run as part of the prompt, and set environment variables for use it it.
dotfiles_prompt_command() {
	# Check if the current directory is a git clone from framer, and if so
	# that the git user is properly configured
	if [ -d .git ] && git remote -v 2>/dev/null | grep -E 'github.com[:/]framer' >/dev/null 2>&1; then
		user=$(git config --get user.email)
		if [ "${user}" = "andreas.kohn@framer.com" ]; then
			git_user_warning=""
		else
			git_user_warning="{${user}} "
		fi
	else
		git_user_warning=""
	fi
}

# Configure the prompt but also expose the previous settings
export DOTFILES_PROMPT_COMMAND="dotfiles_prompt_command; $PROMPT_COMMAND"
PROMPT_COMMAND=$DOTFILES_PROMPT_COMMAND

PS1="\$git_user_warning[\u@\h \W\$git_branch\$git_dirty]\$ "
DOTFILES_PS1="$PS1"
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

# Prefer urxvt, if available
if [ -x urxvt256c ]; then
	export TERMINAL=urxvt256c
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

# Configure auto-completions
GIT_COMPLETION="$DOTFILES_HOME/third-party/git/contrib/completion/git-completion.bash"
test -f "$GIT_COMPLETION" && . "$GIT_COMPLETION"

terraform=$(type -p terraform 2>/dev/null)
if [ -x "${terraform}" ]; then
	complete -C "${terraform}" terraform
fi

stratus=$(type -p stratus 2>/dev/null)
if [ -x "${stratus}" ]; then
	shell_type=$(basename ${SHELL:-/bin/sh})
	stratus_completion=$HOME/.stratus.completion.${shell_type}
	if [ \! -f "${stratus_completion}" ] || [ "${s}" -nt "${stratus_completion}" ]; then
		"${stratus}" completion ${shell_type} > "${stratus_completion}"
	fi
	source "${stratus_completion}"
fi

# macOS-compatible copy/paste helpers
# See https://medium.com/@codenameyau/how-to-copy-and-paste-in-terminal-c88098b5840d
alias pbcopy='xsel --clipboard --input'
alias pbpaste='xsel --clipboard --output'

# Add the standard go binary path
gopath=$(go env GOPATH || echo "")
if [ -n "${gopath}" ]; then
	export PATH=$PATH:${gopath}/bin
fi

# Configure docker tools to use podman, if that is available
podman_socket=$(podman info --format '{{.Host.RemoteSocket.Path}}' 2>/dev/null)
if [ -n "${podman_socket}" ]; then
	export DOCKER_HOST=unix://${podman_socket}
fi

# On macOS, if colima is installed: Point to the colima socket. Note that this check
# doesn't require colima to run.
if [ -d "${HOME}/.colima" ]; then
	export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
fi

# Include the user's .bashrc
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
