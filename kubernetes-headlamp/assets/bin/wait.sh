#!/bin/bash

waitForCompletion() {
	local -r delay='0.75'
	local spinstr='\|/-'
	local temp
	while true; do
		sudo grep -i "done" $1 &>/dev/null
		if [[ "$?" -ne 0 ]]; then
			temp="${spinstr#?}"
			printf " [%c]  " "${spinstr}"
			spinstr=${temp}${spinstr%"${temp}"}
			sleep "${delay}"
			printf "\b\b\b\b\b\b"
		else
			break
		fi
	done
	printf "    \b\b\b\b"
	echo ""
}

showProgress() {
	echo -n "Add headlamp helm repo"
	waitForCompletion /tmp/.headlamprepoadded
	echo -n "Installing Headlamp"
	waitForCompletion /tmp/.headlampinstalled

	echo "All Set"
	echo ""
}

showProgress