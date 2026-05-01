SCENARIO_DIRS := $(patsubst %/index.json,%,$(wildcard */index.json))

.PHONY: scripts
scripts:
	@for dir in $(SCENARIO_DIRS); do \
		echo "Copying scripts to $$dir"; \
		mkdir -p "$$dir/assets/bin"; \
		cp scripts/background.sh "$$dir/background.sh"; \
		cp scripts/clear.sh "$$dir/clear.sh"; \
		cp scripts/foreground.sh "$$dir/foreground.sh"; \
		cp scripts/kutils.sh "$$dir/assets/bin/kutils.sh"; \
	done