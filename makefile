.POSIX:
.SUFFIXES:
.PHONY: build clean serve

LOWDOWN = lowdown
SRC = doc/static
TPL = doc/layout/template.html
OUT = out

build:
	@command -v $(LOWDOWN) >/dev/null 2>&1 || { \
		printf 'make: %s not found\n' $(LOWDOWN) >&2; \
		exit 1; \
	}
	@rm -rf $(OUT)
	@mkdir -p $(OUT)
	@cp -R $(SRC)/. $(OUT)/
	@(cd $(SRC) && find . -name '*.md') | while read -r f; do \
		printf '%s\n' "CC $$f"; \
		t=$${f##*/}; \
		t=$${t%.md}; \
		case $$t in index) t=home ;; esac; \
		$(LOWDOWN) -Thtml "$(SRC)/$$f" | \
			sed -e '/%%CONTENT%%/r /dev/stdin' $(TPL) | \
			sed -e '/%%CONTENT%%/d' \
				-e "s|%%TITLE%%|$$t|" \
			> "$(OUT)/$${f%.md}.html"; \
	done

clean:
	rm -rf $(OUT)

serve: build
	@printf 'Serving site at http://localhost:8000\n'
	@cd $(OUT) && exec python3 -m http.server 8000
