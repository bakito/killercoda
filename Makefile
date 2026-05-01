.PHONY: scripts
scripts:
	cp scripts/foreground.sh kubernetes-headlamp/foreground.sh
	cp scripts/clear.sh  kubernetes-headlamp/clear.sh
	cp scripts/background.sh  kubernetes-headlamp/background.sh
	cp scripts/wait.sh kubernetes-headlamp/assets/bin/wait.sh