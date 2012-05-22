Client side live preview of Markdown for Gollum with syntax highlighting.

[Click for demo.](http://bootstraponline.github.com/livepreview/)

Uses code/assets from:

0. [ace](https://github.com/ajaxorg/ace)
0. [gollum](https://github.com/github/gollum)
0. [highlightjs](https://github.com/isagalaev/highlight.js)
0. [jquery](https://github.com/jquery/jquery)
0. [sizzle](https://github.com/jquery/sizzle)
0. [notepages](https://github.com/fivesixty/notepages)
0. [pagedown](https://code.google.com/p/pagedown/)
0. [retina_display_icon_set](http://blog.twg.ca/2010/11/retina-display-icon-set/)
0. [debounce](https://github.com/cowboy/jquery-throttle-debounce)

See licenses folder for details.

# Dependency Notes

## Ace
Using master branch at [c9c811794f46a3d53b2171bc46e25e613d07d7aa](https://github.com/ajaxorg/ace/commit/c9c811794f46a3d53b2171bc46e25e613d07d7aa). Download files to: `/livepreview/js/ace/`

    # working directory is /livepreview/js/ace/
    rm ace.js mode-markdown.js theme-twilight.js ;\
    wget https://raw.github.com/ajaxorg/ace/master/build/src/ace.js ;\
    wget https://raw.github.com/ajaxorg/ace/master/build/src/mode-markdown.js ;\
    wget https://raw.github.com/ajaxorg/ace/master/build/src/theme-twilight.js

## Building highlightjs
- Using master branch at [237bc62f72065184b63a6fe1823912e4833d3068](https://github.com/isagalaev/highlight.js/commit/237bc62f72065184b63a6fe1823912e4833d3068).

- `isagalaev-highlight.js/tools$ python build.py`

- Copy highlight.pack.js and languages folder to: `/livepreview/js/highlightjs/`

- Note that github.css (`isagalaev-highlight.js/src/styles/github.css` -> `/livepreview/css/highlightjs/`)  has been customized and should not be replaced when updating the highlightjs dependency.

## jQuery & Sizzle
Using jQuery v1.7.2.

- Download latest production version from [jquery.com](http://www.jquery.com).

## Pagedown
The Pagedown code used is from revision `44a4db795617`, Mar 2, 2012 (currently the newest version at the time of writing this document). Markdown.Converter.js has been enhanced to support Gollum style code highlighting. Markdown.Sanitizer.js has been fixed to not remove h4-6.

`https://code.google.com/p/pagedown/source/detail?r=44a4db795617288ae9817c90735fb497891ede23`
