#!/bin/sh

terraform=$(type -p terraform 2>/dev/null)
if [ -x "${terraform}" ]; then
	complete -C "${terraform}" terraform
fi
unset terraform