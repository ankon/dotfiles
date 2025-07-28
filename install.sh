#/bin/sh

echo "WARNING: Incomplete, and will likely destroy existing configuration" >&2
exit 1

MACHINE=$(sudo dmidecode -s system-product-name)

install_common() {
	for f in .gitconfig .vimrc .vim/colors/* .gdbinit .Xresources .bash_profile .bashrc .bashrc.d/*.sh .ssh/config.d/*; do
		mkdir -p $(dirname $HOME/$f)
		ln -sf "$PWD/$f" "$HOME/$f"
	done
	ln -sf "$PWD/.gitignore_global" "$HOME/.gitignore"

	mkdir -p "$HOME/.local/bin"
	for f in gpg-wrapper; do
		ln -sf "$PWD/bin/$f" "$HOME/.local/bin/$f"
	done

	# Include the ~/.ssh/config.d contents
	if grep 'Include config.d/*' $HOME/.ssh/config >/dev/null 2>&1; then
		# All good
		:
	else
		(echo 'Include config.d/*'; cat "$HOME/.ssh/config") > /tmp/ssh_config && mv /tmp/ssh_config "$HOME/.ssh/config"
	fi
}

install_linux() {
	# Install dnf5 first
	type -t dnf5 >/dev/null || sudo dnf install -y dnf5 dnf5-plugins
	# See discussion in https://fedoraproject.org/wiki/Changes/ReplaceDnfWithDnf5
	if [ "$(readlink /usr/bin/dnf)" = "dnf-3" ]; then
		echo "Replacing dnf-3 with dnf5" >&2
		sudo ln -sf dnf5 /usr/bin/dnf
		sudo ln -sf dnf5 /usr/bin/yum
	fi

	# Enable RPM Fusion repositories
	sudo dnf5 install \
		https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
		https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

	# Enable third-party repositories

	# Install packages
	# NB: To switch the default editor for the complete system:
	# `dnf install -y --allowerasing vim-default-editor`
	sudo dnf5 install --skip-unavailable --allowerasing \
		apg \
		arandr \
		argyllcms \
		blueman \
		btop \
		colordiff \
		cmake \
		fastfetch \
		fontconfig \
		gcc \
		gcc-c++ \
		gimp \
		git-credential-libsecret \
		git-lfs \
		git-subtree \
		gnome-keyring \
		gnupg2 \
		htop \
		iftop \
		iotop-c \
		logiops \
		make \
		mc \
		mpc \
		mpd \
		mpv \
		mtr \
		nss-tools \
		openssh-askpass \
		openssl \
		patchutils \
		pinentry-gtk \
		podman \
		podman-docker \
		rpm-build \
		rxvt-unicode \
		seahorse \
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
		colord \
		wayland-utils \
		waypipe \
		wdisplays \
		wf-recorder \
		slurp

	# Change the default editor and remove nano
	sudo dnf5 install --allowerasing \
		vim-default-editor
	sudo dnf5 remove nano

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

	if ! rpm -q SwayNotificationCenter; then
		sudo dnf copr enable erikreider/SwayNotificationCenter
		sudo dnf install SwayNotificationCenter
	fi
	sudo dnf remove dunst

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
	mkdir -p "$HOME/.local/share/applications"
	for f in "$PWD/.local/share/applications"/*; do
		ln -sf "$PWD/$f" "$HOME/$f"
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

	# Enable mpd as a user server
	systemctl enable --now --user mpd

	# Install docker-compose
	DOCKER_CONFIG=${DOCKER_CONFIG:-$HOME/.docker}
	if test -x "${DOCKER_CONFIG}/cli-plugins/docker-compose"; then
		mkdir -p $DOCKER_CONFIG/cli-plugins
		curl -SL https://github.com/docker/compose/releases/download/v2.39.1/docker-compose-linux-$(uname -m) -o "${DOCKER_CONFIG}/cli-plugins/docker-compose"
		chmod +x "${DOCKER_CONFIG}/cli-plugins/docker-compose"

		# Clean up from previous setups
		rm -f ~/.local/bin/docker-compose
	fi

	# Configure logiops
	# XXX: This might need some patching for https://github.com/PixlOne/logiops/issues/402
	sudo ln -sf "$PWD/etc.Linux/logid.cfg" /etc/logid.cfg

	# Configure tmpfiles.d
	for f in "$PWD/etc.Linux/tmpfiles.d/*"; do
		sudo ln -sf "$f" "/etc/tmpfiles.d/$(basename $f)"
	done

	# Install services to configure system-dependent things
	for f in $(find "$PWD/etc.Linux/systemd/system" "$PWD/etc.Linux.${MACHINE}/systemd/system" -type f 2>/dev/null); do
		sudo ln -sf "$f" "/etc/systemd/system/$(basename $f)"
	done
	sudo systemctl daemon-reload

	# Install AWS CLI v2
	curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "/tmp/awscliv2.zip"
	_aws_update=
	if command -v aws; then
		_aws_update=--update
	fi
	(cd /tmp && rm -rf aws && unzip -q awscliv2.zip && ./aws/install --bin-dir ~/.local/bin --install-dir ~/.local/aws-cli ${_aws_update} && aws --version && rm -rf aws /tmp/awscliv2.zip)
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
