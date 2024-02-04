#
# ~/.bashrc
#

du -sh "$HOME" | sed "s|$HOME|\$HOME|g"
du -sh "$PREFIX" | sed "s|$PREFIX|\$PREFIX|g"
echo
ip a | awk '/inet / && !/127.0.0.1/{print $2}'
