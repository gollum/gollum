Sanitization Rules
==================

Gollum uses the [Sanitize](http://wonko.com/post/sanitize) gem for HTML
sanitization. Below you find the default allowed tags, attributes, and protocols, as well as directions to customize these settings.

# Default Settings

## ALLOWED TAGS

a, abbr, acronym, address, area, b, big, blockquote, br, button, caption, center, cite, code, col, colgroup, dd, del, dfn, dir, div, dl, dt, em, fieldset, font, form, h1, h2, h3, h4, h5, h6, hr, i, img, input, ins, kbd, label, legend, li, map, menu, ol, optgroup, option, p, pre, q, s, samp, select, small, span, strike, strong, sub, sup, table, tbody, td, textarea, tfoot, th, thead, tr, tt, u, ul, var

## ALLOWED ATTRIBUTES

a href, abbr, accept, accept-charset, accesskey, action, align, alt, axis, border, cellpadding, cellspacing, char, charoff, class, charset, checked, cite, clear, cols, colspan, color, compact, coords, datetime, dir, disabled, enctype, for, frame, headers, height, hreflang, hspace, id, img src, ismap, label, lang, longdesc, maxlength, media, method, multiple, name, nohref, noshade, nowrap, prompt, readonly, rel, rev, rows, rowspan, rules, scope, selected, shape, size, span, start, summary, tabindex, target, title, type, usemap, valign, value, vspace, width

## ALLOWED PROTOCOLS

* a href: http, https, mailto, ftp, irc, apt, :relative
* img src: http, https, :relative
* form action: http, https, :relative

# Customizing

To customize these settings, edit your `config.rb` file along the following lines (be sure to run gollum with the `--config` option):

```ruby
sanitizer = Gollum::Sanitization.new
sanitizer.protocols['a']['href'].concat ['ssh', 'vnc'] # Protocols
sanitizer.elements.concat ['customtag1', 'customtag2'] # Tags
sanitizer.attributes['a'].push 'target' # Attributes
Precious::App.set(:wiki_options, {:sanitization => sanitizer})
```
