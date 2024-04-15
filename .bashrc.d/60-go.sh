#!/bin/sh

# Add the standard go binary path
gopath=$(go env GOPATH || echo "")
if [ -n "${gopath}" ]; then
	export PATH=$PATH:${gopath}/bin
fi
unset gopath
