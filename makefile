# SPDX-License-Identifier: Unlicense
.POSIX:
.SUFFIXES:
.PHONY: build clean serve deploy

LOWDOWN = lowdown
WRANGLER = wrangler
SRC = $(SITE)/static
TPL = $(SITE)/layout/template.html
OUT = out/$(SITE)
SITE = ploughboy.xyz

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
	rm -rf out

serve: build
	@printf 'Serving site at http://localhost:8000\n'
	@cd $(OUT) && exec python3 -m http.server 8000

deploy: build
	@command -v $(WRANGLER) >/dev/null 2>&1 || { \
		printf 'make: %s not found\n' $(WRANGLER) >&2; \
		exit 1; \
	}
	@test -f $(SITE)/project || { \
		printf 'make: %s/project not found\n' $(SITE) >&2; \
		exit 1; \
	}
	$(WRANGLER) pages deploy $(OUT) \
		--project-name "$$(cat $(SITE)/project)"
