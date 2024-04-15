#!/bin/sh

notbrew() {
    echo "Homebrew isn't available here. Use dnf. Figure out why the caller wants it. Make them feature-detect first." >&2
    echo "Original command line: $@" >&2
    return 1
}

case $(uname) in
    Darwin)
        ;;
    *)
        # macOS-compatible copy/paste helpers
        # See https://medium.com/@codenameyau/how-to-copy-and-paste-in-terminal-c88098b5840d
        alias pbcopy='xsel --clipboard --input'
        alias pbpaste='xsel --clipboard --output'

        # catch attempts to homebrew
        export notbrew
        alias brew=notbrew

        alias open=xdg-open
        
        # TODO: add `ditto` as a cp(1) wrapper
        ;;
esac

