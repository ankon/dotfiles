#/bin/sh

DENO_INSTALL=$HOME/.deno
if [ -d "${DENO_INSTALL}" ]; then
	export DENO_INSTALL
	export PATH=$DENO_INSTALL/bin:$PATH
fi
