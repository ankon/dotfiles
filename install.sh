#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

install_common() {
	for f in .bash_profile .gitconfig .vimrc .Xresources; do
		ln -sf "$PWD/$f" "$HOME/$f"
	done

	mkdir "$HOME/.local/bin"
	for f in gpg-wrapper; do
		ln -s "$PWD/bin/$f" "$HOME/.local/bin/$f"
	done
}

install_linux() {
	# Install custom mime types
	for config in .local/share/mime/*.xml; do
	    xdg-mime install "${config}"
	done
	update-mime-database ~/.local/share/mime/
}

install_darwin() {
	# Install software
	# XXX: This requires homebrew to use /usr/local as prefix; on Apple Silicon that is by default not the case!
	brew install bash gpg pinentry-mac

	# Install keybindings
	mkdir -p ~/Library/KeyBindings
	ln -sf $PWD/Library/KeyBindings/DefaultKeyBinding.dict ~/Library/KeyBindings/DefaultKeyBinding.dict
	# Install GPG config
	mkdir -p ~/.gnupg
	ln -sf $PWD/.gnupg.Darwin/gpg-agent.conf ~/.gnupg/gpg-agent.conf

	echo /usr/local/bin/bash | sudo tee -a /etc/shells
	chsh -s /usr/local/bin/bash

	for f in code docker docker-compose; do
		ln -sf "$PWD/bin.Darwin/$f" "$HOME/.local/bin/$f"
	done
}

# Ensure submodule things are initialized
git submodule init && git submodule update

# Link common content
install_common

# Install OS-specific parts
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
