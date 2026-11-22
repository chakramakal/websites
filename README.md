# websites

Static websites made with Markdown and Make. There is one directory per
site:

* `ploughboy.xyz`, the website for my band.
* `chakramakal.pages.dev`, my personal website.

## Layout

Each site directory holds:

* `static/`, which is copied as it is into the output. Every `.md` file
  in it is also converted to HTML.
* `layout/`, the HTML templates. `template.html` is the default. A
  template named after a top-level directory of `static/`, such as
  `en.html`, is used for the pages in that directory.
* `project`, the name of the Cloudflare Pages project.

## Building

The tools needed are `make`, [lowdown](https://kristaps.bsd.lv/lowdown/),
Python 3 for `serve`, and `wrangler` for `deploy`. `SITE` picks the site
and defaults to `ploughboy.xyz`.

	make build SITE=chakramakal.pages.dev
	make serve SITE=chakramakal.pages.dev
	make deploy SITE=chakramakal.pages.dev
	make clean

The output goes to `out/<site>`.

## Licence

The code is released under the Unlicense, see `LICENSE.md`. The content of
each site is licensed as stated on that site, except that the content of
`ploughboy.xyz`, including its logo, is not covered by the Unlicense.
