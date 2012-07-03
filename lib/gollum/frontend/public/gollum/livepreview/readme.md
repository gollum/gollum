Client side live preview of Markdown for Gollum with syntax highlighting.

[Click for demo.](http://bootstraponline.github.com/livepreview/public)

Uses code/assets from:

0. [ace](https://github.com/ajaxorg/ace)
0. [gollum](https://github.com/github/gollum)
0. [jquery](https://github.com/jquery/jquery)
0. [sizzle](https://github.com/jquery/sizzle)
0. [notepages](https://github.com/fivesixty/notepages)
0. [retina_display_icon_set](http://blog.twg.ca/2010/11/retina-display-icon-set/)
0. [debounce](https://github.com/cowboy/jquery-throttle-debounce)
0. [requirejs](https://github.com/jrburke/requirejs)
0. [emscripten](https://github.com/kripken/emscripten)
0. [sundown](https://github.com/bootstraponline/sundown)

See licenses folder for details.

# Updating gollum

 - /public/css/custom.css (not css/gollum/)
 - /public/images/*
 - /public/js/*
 - /public/licenses/*
 - /public/index.html
 - readme.md
 - replace template.css link in index.html

# Dependency Notes

## Ace
Using master branch at [a091a627a09d5530747576869fefe797816ec4b6](https://github.com/ajaxorg/ace/commit/a091a627a09d5530747576869fefe797816ec4b6).

- Copy `ajaxorg/ace/lib/ace` to `/public/js/ace/lib/ace`

All changes to Ace for livepreview have been upstreamed.
- Gutter control [#799](https://github.com/ajaxorg/ace/pull/799)
- GitHub theme [#798](https://github.com/ajaxorg/ace/pull/798)

## jQuery & Sizzle
Using jQuery v1.7.2.

- Download latest production version from [jquery.com](http://www.jquery.com).

## Sundown & emscripten

- Install emscripten
- src/settings.js must be edited to include _str_to_html in exported functions.
> var EXPORTED_FUNCTIONS = ['_main', '_malloc', '_free', '_str_to_html'];
- Run to_js.sh after checking out the emscripten Sundown repository
- Copy the o2 version into livepreview
- Based on upstrean Sundown [c744346e507e7f905d4b401de78db4404068a43c](https://github.com/tanoku/sundown/commit/c744346e507e7f905d4b401de78db4404068a43c)
