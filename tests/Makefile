rise-test:
	@container_id := $(shell docker ps -q | head -n 1 )
	@token := $(shell docker exec ${container_id} jupyter lab list 2>&1 | grep -o "token=[^ ]*" | cut -d= -f2)
	@python3 tests/rise_click.py ${token}


checksum-test:
	@CHECKSUM := $(shell make checksum )
	@CORRECT_CHECKSUM=$(shell cat base/checksum.txt )
	@if [[ "${CHECKSUM} == ${CORRECT_CHECKSUM}" ]]; then \
		echo "SUCCESS" \
	else \
		echo "FAILURE" \
		echo "Here is the image checksum:" \
		echo "  ${CHECKSUM}" \ 
		echo "Here is the correct checksum:" \
		echo "  ${CORRECT_CHECKSUM}" \
	fi

clean:
	rm -rf *.png
	rm -rf *.ipynb
	rm -rf .ipynb_checkpoints

