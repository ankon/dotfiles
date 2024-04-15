# `.bashrc.d`

Fedora 39's default `.bashrc` contains this block at the end:

```sh
# User specific aliases and functions
if [ -d ~/.bashrc.d ]; then
    for rc in ~/.bashrc.d/*; do
        if [ -f "$rc" ]; then
            . "$rc"
        fi
    done
fi
unset rc
```

This allows the dotfiles project to just define small snippets and install those, and not have to touch the default configuration at all. The dotfiles `.bashrc` includes that snippet, but also sorts the files based on their name, so that there can be basic dependencies between them.