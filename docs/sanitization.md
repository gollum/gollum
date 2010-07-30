Sanitization Rules
==================

Gollum uses the [Sanitize](http://wonko.com/post/sanitize) gem for HTML
sanitization.

See `lib/gollum.rb` for actual settings.

## ALLOWED TAGS

a, abbr, acronym, address, area, b, big, blockquote, br, button, caption,
center, cite, code, col, colgroup, dd, del, dfn, dir, div, dl, dt, em,
fieldset, font, form, h1, h2, h3, h4, h5, h6, hr, i, img, input, ins, kbd,
label, legend, li, map, menu, ol, optgroup, option, p, pre, q, s, samp,
select, small, span, strike, strong, sub, sup, table, tbody, td, textarea,
tfoot, th, thead, tr, tt, u, ul, var

## ALLOWED ATTRIBUTES

abbr, accept, accept-charset, accesskey, action, align, alt, axis, border,
cellpadding, cellspacing, char, charoff, charset, checked, cite, class, clear,
cols, colspan, color, compact, coords, datetime, dir, disabled, enctype, for,
frame, headers, height, href, hreflang, hspace, id, ismap, label, lang,
longdesc, maxlength, media, method, multiple, name, nohref, noshade, nowrap,
prompt, readonly, rel, rev, rows, rowspan, rules, scope, selected, shape,
size, span, src, start, summary, tabindex, target, title, type, usemap,
valign, value, vspace, width

## ALLOWED PROTOCOLS

a href: http, https, mailto
img src: http, https