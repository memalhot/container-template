# ----- Test Targets -----
rise-test: CONT_ID ?= $(shell docker ps -q | head -n 1 )
rise-test: TOKEN ?= $(shell docker exec $(CONT_ID) jupyter lab list 2>&1 | grep -o "token=[^ ]*" | cut -d= -f2)
rise-test:
	python3 rise_test.py $(TOKEN)


checksum-test: CHECKSUM ?= $(shell make -C .. checksum )
checksum-test: CORRECT_CHECKSUM ?= $(shell cat ../base/checksum )
checksum-test:
	@if [[ "$(CHECKSUM) == $(CORRECT_CHECKSUM)" ]]; then \
		echo "SUCCESS" \
	else \
		echo "FAILURE" \
		echo "Here is the image checksum:" \
		echo "  $(CHECKSUM)" \
		echo "Here is the correct checksum:" \
		echo "  $(CORRECT_CHECKSUM)" \
	fi

screenshots-test: screenshots
screenshots-test:
	python3 screenshots_diff.py

# ----- Development Targets -----
screenshots: CONT_ID ?= $(shell docker ps -q | head -n 1 )
screenshots: TOKEN ?= $(shell docker exec $(CONT_ID) jupyter lab list 2>&1 | grep -o "token=[^ ]*" | cut -d= -f2)
screenshots:
	python3 mkscreenshots.py $(TOKEN)

base_screenshots: screenshots
base_screenshots:
	mv *.png base_screenshots


clean:
	rm -rf *.png
	rm -rf *.ipynb
	rm -rf .ipynb_checkpoints

