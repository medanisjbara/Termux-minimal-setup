#!/bin/bash

_CUR_DIR="$(dirname "$(realpath "$0")")"
TOYBOX="/system/bin/toybox"
WRAPPER="$_CUR_DIR/scripts/wrapper"

PATCHES=(
	"pkg_grep_portability.patch"
)

# First update
yes | pkg update

# Install dependencies
dependencies=(
	"dropbear"
	"openssh-sftp-server"
	"busybox"
	"vis"
	"lynx"
	"tur-repo"
	"play-audio"
	"ncdu"
	"termux-services"
	"tcc"
)

for dep in "${dependencies[@]}"; do
	yes | pkg install "$dep"
done

# Clean unneded stuff
trash_files=(
	"$PREFIX"/etc/motd*
	"$PREFIX"/share/man
	"$PREFIX"/share/doc
	"$PREFIX"/share/info
)

for file in "${trash_files[@]}"; do
	echo "Removing $file"
	rm -r "$file"
done

# Setup password
echo -e 'termux\ntermux' | passwd

# Convert into a busybox system
(
	cd "$PREFIX/bin" || exit 1
	echo "Installing busybox..."
	for applet in $(busybox --list); do
		[ "$applet" = top ] && continue
		[ -e "$applet" ] && busybox rm "$applet"
		busybox ln -s busybox "$applet"
	done
	echo "Busybox install..."
	# Enrich with toybox if available
	if [ -e "$TOYBOX" ]; then
		ln -s "$TOYBOX" toybox
		for applet in $(toybox); do
			[ -e $applet ] || ln -s toybox "$applet"
		done
	fi

	# Add tar wrapper
	# Needed for apt to work with busybox tar
	[ -e "$WRAPPER" ] && cp "$WRAPPER" tar

	# Vim stuff
	[ -L vi ] && rm vi && ln -s vis vi
	if [ -L vim ]; then
		rm vim
		ln -s vis vim
	elif [ ! -e vim ]; then
		ln -s vis vim
	fi
)

# Apply compatibility patches (mostly for busybox)
(
	cd "$PREFIX" || exit 1
	for patch in "${PATCHES[@]}"; do
		echo "Applying $patch ..."
		patch -p1 -i "$_CUR_DIR/patches/$patch"
	done
	cp "$WRAPPER" bin/tar
	chmod +x bin/tar
)
