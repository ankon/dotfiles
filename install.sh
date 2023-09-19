#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

install_common() {
	for f in .bash_profile .gitconfig .vimrc .vim/colors/* .Xresources; do
		mkdir -p $(dirname $HOME/$f)
		ln -sf "$PWD/$f" "$HOME/$f"
	done
	ln -s "$PWD/.gitignore_global" "$HOME/.gitignore"

	mkdir "$HOME/.local/bin"
	for f in gpg-wrapper; do
		ln -s "$PWD/bin/$f" "$HOME/.local/bin/$f"
	done
}

install_linux() {
	# Enable RPM Fusion repositories
	sudo dnf install \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	# Enable third-party repositories

	# Install packages
	# NB: To switch the default editor for the complete system:
	# `dnf install -y --allowerasing vim-default-editor`
	sudo dnf install \
		apg \
		arandr \
		argyllcms \
		blueman \
		colordiff \
		fontconfig \
		git-subtree \
		gnome-keyring \
		gnupg2 \
		mc \
		nss-tools \
		patchutils \
		pinentry-gtk \
		rxvt-unicode \
		simplescreenrecorder \
		vim \
		volumeicon \
		wiggle \
		xsel \
		xwininfo

	# Install additional DNF plugins
	sudo dnf install \
		'dnf-command(versionlock)'

	# Install custom mime types
	for config in .local/share/mime/*.xml; do
	    xdg-mime install "${config}"
	done
	update-mime-database "$HOME/.local/share/mime/"

	# Install fonts
	mkdir -p "$HOME/.local/share/fonts"
	find third-party/JetBrainsMono/fonts/ -type f -exec cp {} "$HOME/.local/share/fonts" \;
	fc-cache -f

	for d in .config/*; do
		for f in "$d"/*; do
			ln -sf "$PWD/$f" "$HOME/$f"
		done
	done

	for f in "$PWD/bin.Linux"/*; do
		ln -sf "$f" "$HOME/.local/bin/$f"
	done

	# Enable notifications for blueman; if pairing fails disable these
	# to hopefully switch it into the annoying-but-working "use dialog for everything"
	# approach
	gsettings set org.blueman.general notification-daemon true
}

install_darwin() {
	# Install software
	# XXX: This requires homebrew to use /usr/local as prefix; on Apple Silicon that is by default not the case!
	brew install \
		bash \
		colordiff \
		gpg \
		patchutils \
		pinentry-mac \
		wiggle

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
