# 5.3.0 / 2022-05-25

* Feature: allow for overriding only specific Mustache templates/partials (@beporter)
* Feature: Add option to show browser's local time (@NikitaIvanovV)
* Improvement: presentation on mobile devises (@benjaminwil)
* Improvement: Add page context to template filter. #1603 (@tevino)
* Fix: restore normalize check on file upload (@manofstick)
* Fix mathjax on edit and create pages. #1772 (@fhchl)
* Fix utf-8 issues: #1721 #1758 #1801 (@basking2, @dometto)
* Fix an IME rendering issue. #1735 (@yy0931)
* Fix broken history button when viewing historical deleted file. (@NikitaIvanovV)
* Fix: non-ascii characters in page names are not rendered correctly in the preview tab of the "Edit" page. #1739 (@yy0931)
* Fix: anchors and header display on JRuby. #1779
# 5.2.3 / 2021-04-18

* Fix bug preventing page titles from being displayed

# 5.2.1 / 2021-02-25

* Fix include call to a missing asset (@benjaminwil). This caused slow first page loads on JRuby.

# 5.2 / 2021-02-24

* Improved styling and Primer upgrade (@benjaminwil)
* Add redirect to rename commit (@ViChyavIn)
* Updated dependencies
* Bugfixes

# 5.1.2

* Guard against malicious filenames in breadcrumbs

# 5.1

* Bugfixes
* Add autosave feature (#1576)
* Add quick access to diff of each commit in the history

# 5.0 / 2020-03-17

This is a major new release that introduces many new features, bugfixes, and removes major limitations. See [here](https://github.com/gollum/gollum/wiki/5.0-release-notes) for a list of changes.

**Note**: due to changes to the way in which Gollum handles filenames, you may have to change some links in your wiki when migrating from gollum 4.x. See the [release notes](https://github.com/gollum/gollum/wiki/5.0-release-notes#migrating-your-wiki) for more details. You may be find the `bin/gollum-migrate-tags` script helpful to accomplish this. Also see the `--lenient-tag-lookup` option for making tag lookup backwards compatible with 4.x, though note that this will decrease performance on large wikis with many tags.

Many thanks to all the users who have provided feedback, and everyone who has chipped in in the development process!

Many of these changes have been made possible by removing the default grit adapter in favour of the new [rugged adapter](https://github.com/gollum/rugged_adapter).

# 4.1.4 /2018-01-10

* Depend on new version of gollum-lib that relies on a patched version of sanitize, which solves a vulnerability (CVE-2018-3740). See https://github.com/gollum/gollum-lib/pull/296.

# 4.1.3 /2018-17-09

* Solves a vulnerability in the File view and All Pages view that would allow XSS.

# 4.1.2 /2017-08-07

* Lock to a newer version of gollum-lib to avoid installing an outdated and vulnerable dependency (nokogiri) on ruby 2.0. See https://github.com/gollum/gollum-lib/pull/279. Note: this breaks semantic versioning so those using outdated rubies will discover the problem on update.

# 4.1.0 /2017-03-09

* Added file deletion functionality to file view
* Various performance improvements
* Emoji support

# 4.0.0 /2015-04-11

* Now compatible with JRuby (via the [rjgit](https://github.com/repotag/rjgit) [adapter](https://github.com/repotag/gollum-lib_rjgit_adapter))

# 3.1.1 /2014-12-04

* Security fix for [remote code execution issue](https://github.com/gollum/gollum/issues/913). Please update!

# 3.1 / 2014-11-28

* New features
  * Drag-and-drop uploading in the editor [@lucas-clemente](https://github.com/lucas-clemente)
  * Latest changes view [@etienneCharignon](https://github.com/etienneCharignon) (#707)
  * Option `--no-edit` to disable editing from the web interface [@bambycha](https://github.com/bambycha) (#879)
  * Option `--mathjax-config` to specify custom mathjax configuration [@hardywu](https://github.com/hardywu) (#842)
* Major enhancements
  * Made the Gollum theme responsive [@rtrvrtg](https://github.com/rtrvrtg) (#831)
  * Depends on new [gollum-lib](https://github.com/gollum/gollum-lib) `4.0.0`
    * Allows specifying [git adapter](https://github.com/gollum/gollum/wiki/Git-adapters) with `--adapter` [@bartkamphorst](https://github.com/bartkamphorst), [@dometto](https://github.com/dometto)
* Numerous bugfixes
  * **NB**: please pass `--h1-title` if you do not want page titles to default to the page's filepath. See [here](https://github.com/gollum/gollum/wiki/Page-titles).

# 2.4.11 / 2013-01-08

* Numerous security issues have been fixed. Please update to `2.4.11`

# 1.4.0 / 2012-04-10

* Minor
  * Add a way to configure the `#id_prefix` property of Sanitization
    objects.
  * Add web sequence diagrams support
  * Support for updating wysiwyg components when markup language changes
  * Support RedCarpet 2.0
  * Allow ftp and irc links in wiki markup
  * Minor ui fixups

* Bug Fixes
  * Include the language of the code snippet when making a uniquely
    identifiable sha of a code snippet while rendering a page.
  * Pygments lexer forces utf8 encoding
  * Remove MathJax, this created problems in production for us.
    We'll look at bringing it back in future releases

# 1.3.1 / 2011-07-21

* Major Enhancements
  * Allow prefixed ID attributes in headers to support internal linking
    (#146).
  * Markdown pages are rendered through Redcarpet by default (#176).
* Minor Enhancements
  * Remove Edit button on Preview pages (#164).
  * Simplify Wiki#inspect and Page#inspect.
* Bug Fixes
  * Fixed broken preview functionality (#157).
  * Fixed sidebar/footer rendering problems related to whitespace (#145).

# 1.3.0 / 2011-04-25

* Major Enhancements
  * Listing of all Pages
  * Support for running Gollum under a separate branch.
* Minor Enhancements
  * Fix a security issue with rendering Mathjax.

# 1.2.0 / 2011-03-11

* Major Enhancements
  * Major HTML/CSS/JS overhaul.
  * Add Sidebars (similar to Footers).
  * Add commit reverts.
* Minor Enhancements
  * Optimization in source code highlighting, resulting in a huge
    decrease in rendering time.
  * Security fixes related to source code highlighting.

* Major Enhancements
  * Add Page sidebars, similar to Page footers.
  * Add the ability to revert commits to the wiki.
  * Add MediaWiki support.
* Minor Enhancements
  * Add `:sanitization` and `:history_sanitization` options for customizing
    how `Sanitize.clean` modifies formatted wiki content.
  * Add `--config` option for the command line, to specify a ruby file that is
    run during startup.
  * Provide access to a parsed Nokogiri::DocumentFragment during markup
    rendering for added customization.
* Bug Fixes
  * Use `@wiki.page_class` in Gollum::Markup where appropriate (#63).
  * Fix parsing of Org mode file links (#87).

# 1.1.0 / 2010-10-28

* Major Enhancements
  * Optimize page write/update/delete to use Grit::Index::read_tree instead
    of manually recreating entire index contents.
  * Added --irb option for the gollum command.
  * Update working dir (if present) when edited via the API (#6)
  * Add basic `git grep` based search for repos.
* Minor Enhancements
  * Support a `:gollum_path` Sinatra setting for `Precious::App`
  * Add Wiki#size to efficiently count pages without loading them.
  * Add the correct content type when serving files from the frontend.
  * Add --host option and default it to 127.0.0.1.
  * Allow anchors in page links, such as `[[Abc#header]]`.
  * All pages retrieved with a SHA add `rel="nofollow"` to all
    page links.
* Bug Fixes
  * Increase minimum Sanitize version requirement to 1.1.0.
    1.0.x versions of Sanitize require Hpricot instead of Nokogiri
    and have bugs that may allow non-whitelisted HTML to sneak
    through.
  * Introduce Ruby 1.9 compatibility fixes.
  * Commit hashes are normalized so that missing author data is replaced with
    anonymous info.
  * Prevent `Gollum::Wiki#write_page` from clobbering existing pages.
  * Handle duplicate page errors in frontend.
  * Fix bugs trying to retrieve pages with invalid names.
  * CGI escape page names in links and redirects.

# 1.0.1 / 2010-08-12

* Bug Fixes
  * Force Grit dep to 2.1 or higher.

# 1.0.0 / 2010-08-12

* Open Source Birthday!
