#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

install_linux() {
	# Install custom mime types
	for config in .local/share/mime/*.xml; do
	    xdg-mime install "${config}"
	done
	update-mime-database ~/.local/share/mime/
}

install_darwin() {
	# Install keybindings
	mkdir -p ~/Library/KeyBindings
	ln -sf $PWD/Library/KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
	# Install GPG config
	mkdir -p ~/.gnupg
	ln -sf $PWD/.gnupg.Darwin/gpg-agent.conf ~/.gnupg/gpg-agent.conf
}

case "$(uname)" in
	Darwin)
		install_darwin
		;;
	Linux)
		install_linux
		;;
	*)
		;;
esac
