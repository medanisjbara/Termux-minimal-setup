#!/bin/sh
shopt -s extglob

show_usage(){
    echo "Usage: $0 pull"
}

if [ -z "$TERMUX_HOST" ]; then
    echo "Please set variable TERMUX_HOST with termux's IP"
    exit 1
fi

if [ $# -ne 1 ]; then
    show_usage
    exit
fi

case "$1" in
    pull)
        rm -r !("$(basename "$0")")
        scp -rP 8022 "$TERMUX_HOST":termux-setup/* .
        ;;
    *)
        show_usage
        ;;
esac
