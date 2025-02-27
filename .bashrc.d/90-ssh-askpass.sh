#!/bin/sh

# kde-settings gets installed by a bunch of things (such as libreoffice and java) and
# sets `SSH_ASKPASS` to /usr/bin/ksshaskpass -- but that's not depended upon.
if [ -n "${SSH_ASKPASS}" ]; then
	if command -v "${SSH_ASKPASS}"; then
		# All good: The value seems to be pointing to an executable.
		:
	else
		# Value is bad, try to find an alternative.
		# /usr/libexec/openssh/ssh-askpass is a symbolic link, and as such seems to be a good
		# default choice.
		SSH_ASKPASS=
		for maybe_askpass in /usr/libexec/openssh/ssh-askpass /usr/libexec/gnome-ssh-askpass; do
			if command -v "${maybe_askpass}"; then
				SSH_ASKPASS=${makybe_askpass}
				break
			fi
		done
		export SSH_ASKPASS
	fi
fi
