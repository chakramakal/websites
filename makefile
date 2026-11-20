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
		l=$${f#./}; \
		l=$${l%%/*}; \
		tpl=$(SITE)/layout/$$l.html; \
		test -f "$$tpl" || tpl=$(TPL); \
		q=$${f#./}; \
		q=$${q%.md}; \
		test "$$tpl" = "$(TPL)" || q=$${q#*/}; \
		case $$q in \
		index) p= ;; \
		*/index) p=$${q%index} ;; \
		*) p=$$q ;; \
		esac; \
		t=$$(awk 'NR == 1 { if ($$0 != "---") exit; next } \
			$$0 == "---" { closed = 1; exit } \
			/^title:/ && !seen { v = $$0; seen = 1 } \
			END { if (!closed || !seen) exit; \
			sub(/^title:[ \t]*/, "", v); sub(/[ \t]+$$/, "", v); \
			if (v ~ /^".*"$$/ || v ~ /^\047.*\047$$/) \
			v = substr(v, 2, length(v) - 2); print v }' \
			"$(SRC)/$$f"); \
		if test -z "$$t"; then t=$${p%/}; t=$${t:-home}; fi; \
		t=$$(printf '%s\n' "$$t" | sed -e 's/&/\&amp;/g' \
			-e 's/</\&lt;/g' -e 's/>/\&gt;/g' \
			-e 's/[\\&|]/\\&/g'); \
		awk '{ l[NR] = $$0 } END { s = 1; \
			if (l[1] == "---") for (i = 2; i <= NR; i++) \
			if (l[i] == "---") { s = i + 1; break } \
			for (i = s; i <= NR; i++) print l[i] }' \
			"$(SRC)/$$f" | \
			$(LOWDOWN) -Thtml | \
			sed -e '/%%CONTENT%%/r /dev/stdin' "$$tpl" | \
			sed -e '/%%CONTENT%%/d' \
				-e "s|%%TITLE%%|$$t|" \
				-e "s|%%PATH%%|$$p|g" \
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
