#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

install_common() {
	for f in .bash_profile .gitconfig .vimrc .vim/colors/* .Xresources .bashrc.d/*.sh; do
		mkdir -p $(dirname $HOME/$f)
		ln -sf "$PWD/$f" "$HOME/$f"
	done
	ln -sf "$PWD/.gitignore_global" "$HOME/.gitignore"

	mkdir -p "$HOME/.local/bin"
	for f in gpg-wrapper; do
		ln -sf "$PWD/bin/$f" "$HOME/.local/bin/$f"
	done
}

install_linux() {
	# Install dnf5 first
	sudo dnf install -y dnf5
	
	# Enable RPM Fusion repositories
	sudo dnf5 install \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	# Enable third-party repositories

	# Install packages
	# NB: To switch the default editor for the complete system:
	# `dnf install -y --allowerasing vim-default-editor`
	sudo dnf5 install --skip-unavailable \
		apg \
		arandr \
		argyllcms \
		blueman \
		colordiff \
		fontconfig \
		gimp \
		git-credential-libsecret \
		git-lfs \
		git-subtree \
		gnome-keyring \
		gnupg2 \
		htop \
		iftop \
		iotop \
		make \
		mc \
		nss-tools \
		patchutils \
		pinentry-gtk \
		podman \
		podman-docker \
		rxvt-unicode \
		screen \
		simplescreenrecorder \
		vim \
		volumeicon \
		wiggle \
		wireguard-tools \
		xsel \
		xwininfo

	# If running wayland/sway:
	sudo dnf5 install \
		wdisplays # replace arandr/xrandr

	# Install languages
	sudo dnf5 install \
		golang-bin golang-src \
		rust rust-src cargo clippy

	# Install additional DNF plugins
	sudo dnf5 install \
		'dnf-command(versionlock)'

	# Install microsoft software: Edge, VSCode
	sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
	cat <<EOF | sudo tee /etc/yum.repos.d/microsoft.repo
[microsoft-edge-dev]
name=microsoft-edge-dev
baseurl=https://packages.microsoft.com/yumrepos/edge/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc

[code]
name=Visual Studio Code
baseurl=https://packages.microsoft.com/yumrepos/vscode/
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
EOF
	sudo dnf5 install microsoft-edge-dev code-insiders

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
		mkdir -p "$HOME/$d"
		for f in "$d"/*; do
			ln -sf "$PWD/$f" "$HOME/$f"
		done
	done

	for f in "$PWD/bin.Linux"/*; do
		ln -sf "$f" "$HOME/.local/bin/$(basename $f)"
	done

	# Enable notifications for blueman; if pairing fails disable these
	# to hopefully switch it into the annoying-but-working "use dialog for everything"
	# approach
	gsettings set org.blueman.general notification-daemon true

	# Enable podman/docker compatibility and expose the _user_ service socket
	systemctl enable --now --user podman podman.socket
	# Disable the notice that we're using an "emulation" for docker
	sudo touch /etc/containers/nodocker

	# Configure git for the system
	git config --global credential.helper /usr/libexec/git-core/git-credential-libsecret	
}

install_darwin() {
	# Install software
	# XXX: This requires homebrew to use /usr/local as prefix; on Apple Silicon that is by default not the case!
	brew install \
		bash \
		colima \
		colordiff \
		docker-compose \
		git-lfs \
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

	for f in code docker; do
		ln -sf "$PWD/bin.Darwin/$f" "$HOME/.local/bin/$f"
	done

	# Allow XQuartz to accept TCP connections
	# NB: The key depends on where XQuartz came from:
	#   org.xquartz.X11 is for the package
	brew install --cask xquartz
	defaults write org.xquartz.X11 nolisten_tcp -boolean false
	# See other settings using `defaults read org.xquartz.X11`.

	# Colima can be started automatically, but that will reduce battery life.
	#brew services start colima

	# Configure git for the system
	git config --global credential.helper osxkeychain
}

# Ensure submodule things are initialized
git submodule init && git submodule update

# Link common content
install_common

# TODO: Set up nvs node/lts
# TODO: Set up sshd.service (sometimes)

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
