#!/bin/sh

launch_code() {
	nohup gtk-launch code-insiders -- "$@" >/dev/null 2>&1
}

code() {
	# If there are arguments, pass them along. If there are none, or there is just a single
    # directory, look whether we can find a .code-workspace file with the same name as the directory
	# and use that instead.
	c=launch_code
	if [ $# -gt 1 ]; then
		"${c}" "$@"
    else
		d=${1:-.}
		if [ -d "${d}" ]; then
			n=$(cd "${d}" >/dev/null 2>&1; basename "${PWD}")
			ws=${d}/${n}.code-workspace
			if [ -f "${ws}" ]; then
				"${c}" "${ws}"
			else
				"${c}" "${d}"
			fi
		else
			# Assume current directory, not "whatever"
			"${c}" "${d}"
		fi
	fi
}
export code
