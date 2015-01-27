- [sundown + livepreview](http://bootstraponline.github.com/livepreview/public)
- [markdowndeep + livepreview](http://bootstraponline.github.com/livepreview/public/index_deep.html)

Uses code/assets from:

0. [ace](https://github.com/ajaxorg/ace)
0. [gollum](https://github.com/gollum/gollum)
0. [jquery](https://github.com/jquery/jquery)
0. [sizzle](https://github.com/jquery/sizzle)
0. [notepages](https://github.com/fivesixty/notepages)
0. [retina_display_icon_set](http://blog.twg.ca/2010/11/retina-display-icon-set/)
0. [debounce](https://github.com/cowboy/jquery-throttle-debounce)
0. [requirejs](https://github.com/jrburke/requirejs)
0. [emscripten](https://github.com/kripken/emscripten)
0. [sundown](https://github.com/bootstraponline/sundown)
0. [markdowndeep](https://github.com/toptensoftware/markdowndeep)

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
Using master branch at [63178a05119ec425908514a16007743905672dbf](https://github.com/ajaxorg/ace/commit/63178a05119ec425908514a16007743905672dbf).

- Copy `ajaxorg/ace/lib/ace` to `/public/js/ace/lib/ace`

All changes to Ace for livepreview have been upstreamed.
- Gutter control [#799](https://github.com/ajaxorg/ace/pull/799)
- GitHub theme [#798](https://github.com/ajaxorg/ace/pull/798)

## jQuery & Sizzle
Using jQuery v1.7.2.

- Download latest production version from [jquery.com](http://www.jquery.com).
