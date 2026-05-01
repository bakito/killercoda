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
	echo -n "Add crossplane helm repo"
	waitForCompletion /tmp/.crossplanerepoadded
	echo -n "Installing Crossplane"
	waitForCompletion /tmp/.crossplaneinstalled
	echo -n "Installing Crossview"
	waitForCompletion /tmp/.crossviewinstalled

	echo "All Set"
	echo ""
}

showProgress