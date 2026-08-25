#!/usr/bin/env bash

case $(awk -F= '/^ID=/{gsub(/"/, "", $2); print $2}' /etc/os-release) in
	debian|ubuntu|kali|raspbian)
		sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y && sudo apt clean
		;;
	arch|manjaro|endeavouros)
		if command -v yay &> /dev/null; then
			yay -Syu --noconfirm --answerclean None --answerdiff None
		else
			sudo pacman -Syu --noconfirm
		fi
		;;
	*)
		echo "Unsupported distro"
		;;
esac
