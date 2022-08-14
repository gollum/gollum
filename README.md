gollum -- A git-based Wiki
====================================

[![Gem Version](https://badge.fury.io/rb/gollum.svg)](http://badge.fury.io/rb/gollum)
![Build Status](https://github.com/gollum/gollum/actions/workflows/test.yaml/badge.svg)
[![Open Source Helpers](https://www.codetriage.com/gollum/gollum/badges/users.svg)](https://www.codetriage.com/gollum/gollum)
[![Cutting Edge Dependency Status](https://dometto-cuttingedge.herokuapp.com/github/gollum/gollum/svg 'Cutting Edge Dependency Status')](https://dometto-cuttingedge.herokuapp.com/github/gollum/gollum/info)
[![Docker Pulls](https://img.shields.io/docker/pulls/gollumwiki/gollum)](https://hub.docker.com/r/gollumwiki/gollum)

See the [wiki](https://github.com/gollum/gollum/wiki) for extensive documentation, along with [screenshots](https://github.com/gollum/gollum/wiki/Screenshots) of Gollum's features.

## DESCRIPTION

Gollum is a simple wiki system built on top of Git. A Gollum Wiki is simply a git repository of a specific nature:

* A Gollum repository's contents are human-editable text or markup files.
* Pages may be organized into directories any way you choose.
* Other content can also be included, for example images, PDFs and headers/footers for your pages.
* Gollum pages:
	* May be written in a variety of [markups](#markups).
	* Can be edited with your favourite editor (changes will be visible after committing) or with the built-in web interface.
	* Can be displayed in all versions, reverted, etc.
* Gollum strives to be [compatible](https://github.com/gollum/gollum/wiki/5.0-release-notes#compatibility-option) with [GitHub](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis) and [GitLab](https://docs.gitlab.com/ee/user/project/wiki/#create-or-edit-wiki-pages-locally) wikis.
  * Just clone your GitHub/GitLab wiki and view and edit it locally!
	
* Gollum supports advanced functionality like:
  * [UML diagrams](https://github.com/gollum/gollum/wiki#plantuml-diagrams)
  * [BibTeX and Citation support](https://github.com/gollum/gollum/wiki/BibTeX-and-Citations)
  * Annotations using [CriticMarkup](https://github.com/gollum/gollum/wiki#criticmarkup-annotations)
  * Mathematics via [MathJax](https://github.com/gollum/gollum/wiki#mathematics)
  * [Macros](https://github.com/gollum/gollum/wiki/Standard-Macros)
  * [Redirects](https://github.com/gollum/gollum/wiki#redirects)
  * [RSS Feed](https://github.com/gollum/gollum/wiki/5.0-release-notes#rss-feed) of latest changes
  * ...and [more](https://github.com/gollum/gollum/wiki)

### SYSTEM REQUIREMENTS

Gollum runs on Unix-like systems using its default [adapter](https://github.com/gollum/rugged_adapter) for [rugged](https://github.com/libgit2/rugged). You can also run Gollum on [JRuby](https://github.com/jruby/jruby) via its [adapter](https://github.com/repotag/gollum-lib_rjgit_adapter) for [RJGit](https://github.com/repotag/rjgit/). On Windows, Gollum runs only on JRuby.

## INSTALLATION

### As a Ruby Gem

Ruby is best installed either via [RVM](https://rvm.io/) or a package manager of choice. Then simply:
	```
	gem install gollum
	```
	
Installation examples for individual systems can be seen [here](https://github.com/gollum/gollum/wiki/Installation).

To run, simply:

1. Run: `gollum /path/to/wiki` where `/path/to/wiki` is an initialized Git repository.
2. Open `http://localhost:4567` in your browser.

### Via Docker

See [here](https://github.com/gollum/gollum/wiki/Gollum-via-Docker) for instructions on how to run Gollum via Docker.

### Misc

See [below](#running-from-source) for information on running Gollum from source, as a Rack app, and more.

## MARKUPS

Gollum allows using different markup languages on different wiki pages. It presently ships with support for the following markups:
* [Markdown](http://daringfireball.net/projects/markdown/syntax) (see [below](#Markdown-flavors) for more information on Markdown flavors)
* [RDoc](http://rdoc.sourceforge.net/)

You can easily activate support for other markups by installing additional renderers (any that are supported by [github-markup](https://github.com/github/markup)):
* [AsciiDoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/) -- `gem install asciidoctor`
* [Creole](http://www.wikicreole.org/wiki/CheatSheet) -- `gem install creole`
* [MediaWiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`
* [Org](http://orgmode.org/worg/dev/org-syntax.html) -- `gem install org-ruby`
* [Pod](http://perldoc.perl.org/perlpod.html) -- requires Perl >= 5.10 (the `perl` command must be available on your command line)
	* Lower versions should install `Pod::Simple` from CPAN.
* [ReStructuredText](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html) -- requires python >= 3
	* Note that Gollum will also need you to install `docutils` for python
* [Textile](http://redcloth.org/hobix.com/textile/quick.html) -- `gem install RedCloth`

### Markdown flavors

By default, Gollum ships with the `kramdown` gem to render Markdown. However, you can use any [Markdown renderer supported by github-markup](https://github.com/github/markup/blob/master/lib/github/markup/markdown.rb). This includes [CommonMark](https://commonmark.org/) support via the `commonmarker` gem. The first installed renderer from the list will be used (e.g., `redcarpet` will NOT be used if `github/markdown` is installed). Just `gem install` the renderer of your choice.

See [here](https://github.com/gollum/gollum/wiki/Custom-rendering-gems) for instructions on how to use custom rendering gems and set custom options.

## RUNNING FROM SOURCE

1. `git clone https://github.com/gollum/gollum`
2. `cd gollum`
3. `[sudo] bundle install`
4. `bundle exec bin/gollum`
5. Open `http://localhost:4567` in your browser.

### Rack

Gollum can also be run with any [rack-compatible web server](https://github.com/rack/rack#supported-web-servers). More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack).

### Rack, with an authentication server

Gollum can also be run alongside a CAS (Central Authentication Service) SSO (single sign-on) server. With a bit of tweaking, this adds basic user-support to Gollum. To see an example and an explanation, navigate [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack-and-CAS-SSO).

### Service

Gollum can also be run as a service. More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-as-a-service).

## CONFIGURATION

Gollum comes with the following command line options:

| Option            | Arguments | Description |
| ----------------- | --------- | ----------- |
| --host            | [HOST]    | Specify the hostname or IP address to listen on. Default: '0.0.0.0'.<sup>1</sup> |
| --port            | [PORT]    | Specify the port to bind Gollum with. Default: `4567`. |
| --config          | [FILE]    | Specify path to Gollum's [configuration file](#Config-file). |
| --ref             | [REF]     | Specify the git branch to serve. Default: `master`. |
| --bare            | none      | Tell Gollum that the git repository should be treated as bare. |
| --adapter         | [ADAPTER] | Launch Gollum using a specific git adapter. Default: `rugged`.<sup>2</sup> |
| --base-path       | [PATH]    | Specify the leading portion of all Gollum URLs (path info). Setting this to `/wiki` will make the wiki accessible under `http://localhost:4567/wiki/`. Default: `/`. |
| --page-file-dir   | [PATH]    | Specify the subdirectory for all pages. If set, Gollum will only serve pages from this directory and its subdirectories. Default: repository root. |
| --static, --no-static | none  | Use static assets. Defaults to false in development/test,  true in production/staging. |
| --assets          |  [PATH]   | Set the path to look for static assets. |
| --css             | none      | Tell Gollum to inject custom CSS into each page. Uses `custom.css` from wiki root.<sup>3</sup> |
| --js              | none      | Tell Gollum to inject custom JS into each page. Uses `custom.js` from wiki root.<sup>3</sup> |
| --no-edit         | none      | Disable the feature of editing pages. |
| --local-time | none      | Use the browser's local timezone instead of the server's for displaying dates. Default: false.
| --follow-renames, --no-follow-renames  | none      | Follow pages across renames in the History view. Default: true.
| --allow-uploads   | [MODE]    | Enable file uploads. If set to `dir`, Gollum will store all uploads in the `/uploads/` directory in repository root. If set to `page`, Gollum will store each upload at the currently edited page.<sup>4</sup> |
| --mathjax         | none      | Enables MathJax (renders mathematical equations). By default, uses the `TeX-AMS-MML_HTMLorMML` config with the `autoload-all` extension.<sup>5</sup> |
| --critic-markup   | none      | Enable support for annotations using [CriticMarkup](http://criticmarkup.com/). |
| --irb             | none      | Launch Gollum in "console mode", with a [predefined API](https://github.com/gollum/gollum-lib/). |
| --h1-title        | none      | Tell Gollum to use the first `<h1>` as page title. |
| --no-display-metadata | none  | Do not render metadata tables in pages. |
| --user-icons      | [MODE]    | Tell Gollum to use specific user icons for history view. Can be set to `gravatar`, `identicon` or `none`. Default: `none`. |
| --mathjax-config  | [FILE]    | Specify path to a custom MathJax configuration. If not specified, uses the `mathjax.config.js` file from repository root. |
| --template-dir    | [PATH]    | Specify custom mustache template directory. Only overrides templates that exist in this directory. |
| --template-page   | none      | Use _Template in root as a template for new pages. Must be committed. |
| --emoji           | none      | Parse and interpret emoji tags (e.g. `:heart:`) except when the leading colon is backslashed (e.g. `\:heart:`). |
| --default-keybind | none      | Set the default keybinding for the editor. Can be set to `vim`, or `emacs`. |
| --lenient-tag-lookup | none | Internal links resolve case-insensitively, will treat spaces as hyphens, and will match the first page found with a certain filename, anywhere in the repository. Provides compatibility with Gollum 4.x. |
| --help            | none      | Display the list of options on the command line. |
| --version         | none      | Display the current version of Gollum. |
| --versions        | none      | Display the current version of Gollum and auxiliary gems. |

**Notes:**

1. The `0.0.0.0` IP address allows remote access. Should you wish for Gollum to turn into a personal Wiki, use `127.0.0.1`.
2. Before using `--adapter`, you should probably read [this](https://github.com/gollum/gollum/wiki/Git-adapters) first.
3. When `--css` or `--js` is used, respective files must be committed to your git repository or you will get a 302 redirect to the create a page.
4. Files can be uploaded simply by dragging and dropping them onto the editor's text area when `--allow-uploads` is used.

### Config file

When `--config` option is used, certain inner parts of Gollum can be customized. This is used throughout our wiki for certain user-level alterations, among which [customizing supported markups](https://github.com/gollum/gollum/wiki/Formats-and-extensions) will probably stand out.

**All of the mentioned alterations work both for Gollum's config file (`config.rb`) and Rack's config file (`config.ru`).**

## CONTRIBUTING

Please consider helping out! See [CONTRIBUTING](CONTRIBUTING.md) for information on how to submit issues, and how to start hacking on gollum.
