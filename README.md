gollum -- A git-based Wiki
====================================

[![Gem Version](https://badge.fury.io/rb/gollum.svg)](http://badge.fury.io/rb/gollum)
[![Build Status](https://travis-ci.org/gollum/gollum.svg?branch=master)](https://travis-ci.org/gollum/gollum)
[![Dependency Status](https://gemnasium.com/gollum/gollum.svg)](https://gemnasium.com/gollum/gollum)

Note: this is the development branch for the next major release of Gollum, version 5.0. See [here](https://github.com/gollum/gollum/wiki/5.0-release-notes) for a list of changes and new features.

## DESCRIPTION

Gollum is a simple wiki system built on top of Git. A Gollum Wiki is simply a git repository (either bare or regular) of a specific nature:
* A Gollum repository's contents are human-editable, unless the repository is bare. Pages are unique text files which may be organized into directories any way you choose. Other content can also be included, for example images, PDFs and headers/footers for your pages.
* Gollum pages:
	* May be written in a variety of [markups](#markups).
	* Can be edited with your favourite system editor or IDE (changes will be visible after committing) or with the built-in web interface.
	* Can be displayed in all versions (commits).

Gollum can be launched either as a webserver (with the web interface) or in "console mode", where you can use a predefined API to query and manipulate the repository. For more information, see the [Running](#running) and [Configuration](#configuration) sections.

For more information on Gollum's capabilities and pitfalls:

1. [Syntax/capability overview for pages](https://github.com/gollum/gollum/wiki).
2. [Known limitations](https://github.com/gollum/gollum/wiki/Known-limitations).
3. [Troubleshoot guide](https://github.com/gollum/gollum/wiki/Troubleshoot-guide).
4. [Security overview](https://github.com/gollum/gollum/wiki/Security).

### Videos

* [Quick impression of gollum](https://www.youtube.com/watch?v=gj1qqK3Oku8)
* [Gollum overview and simple markdown tutorial (german with english subtitles)](https://www.youtube.com/watch?v=wfWgDRmcbU4)
* [Advanced features in action](https://www.youtube.com/watch?v=EauxgxsLDC4)

## SYSTEM REQUIREMENTS

| Operating System | Ruby           | Adapters           | Supported |
| ---------------- | -------------- | ------------------ | --------- |
| Unix/Linux-like  | Ruby 1.9.3+    | all except [RJGit](https://github.com/repotag/rjgit) | yes |
| Unix/Linux-like  | [JRuby](https://github.com/jruby/jruby) (1.9.3+ compatible) | [RJGit](https://github.com/repotag/rjgit) | yes |
| Windows          | Ruby 1.9.3+    | all except [RJGit](https://github.com/repotag/rjgit) | no  |
| Windows          | [JRuby](https://github.com/jruby/jruby) (1.9.3+ compatible) | [RJGit](https://github.com/repotag/rjgit) | almost<sup>1</sup> |

**Notes:**

1. You can track the progress at [Support Windows via JRuby - Meta Issue](https://github.com/gollum/gollum/issues/1044).

## INSTALLATION

Varies depending on operating system, package manager and Ruby installation. Generally, you should first install Ruby and then Gollum.

1. Ruby is best installed either via [RVM](https://rvm.io/) or a package manager of choice.
2. Gollum is best installed via RubyGems:  
	```
	[sudo] gem install gollum
	```

Installation examples for individual systems can be seen [here](https://github.com/gollum/gollum/wiki/Installation).

### Markups

Gollum presently ships with support for the following markups:
* [Markdown](http://daringfireball.net/projects/markdown/syntax) (see [below](#Markdown-flavors) for more information on Markdown flavors)
* [RDoc](http://rdoc.sourceforge.net/)

You can easily activate support for other markups by installing additional renderers (any that are supported by [github-markup](https://github.com/github/markup)):
* [AsciiDoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/) -- `[sudo] gem install asciidoctor`
* [Creole](http://www.wikicreole.org/wiki/CheatSheet) -- `[sudo] gem install creole`
* [MediaWiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `[sudo] gem install wikicloth`
* [Org](http://orgmode.org/worg/dev/org-syntax.html) -- `[sudo] gem install org-ruby`
* [Pod](http://perldoc.perl.org/perlpod.html) -- requires Perl >= 5.10 (the `perl` command must be available on your command line)
	* Lower versions should install `Pod::Simple` from CPAN.
* [ReStructuredText](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html) -- requires python >= 2 (the `python2` command must be available on your command line)
	* Note that Gollum will also need you to install `docutils` for your Python 2.
* [Textile](http://redcloth.org/hobix.com/textile/quick.html) -- `[sudo] gem install RedCloth`

### Markdown flavors

By default, Gollum ships with the `kramdown` gem to render Markdown. However, you can use any [Markdown renderer supported by github-markup](https://github.com/github/markup/blob/master/lib/github/markup/markdown.rb). This includes [CommonMark](https://commonmark.org/) support via the `commonmarker` gem. The first installed renderer from the list will be used (e.g., `redcarpet` will NOT be used if `github/markdown` is installed). Just `gem install` the renderer of your choice.

See [here](https://github.com/gollum/gollum/wiki/Custom-rendering-gems) for instructions on how to use custom rendering gems and set custom options.

## RUNNING

Simply:

1. Navigate to your git repository (wiki) via the command line.
2. Run: `gollum`.
3. Open `http://localhost:4567` in your browser.

This will start up a web server (WEBrick) running Gollum with a web interface, where you can view and edit your wiki.

### Running from source

1. `git clone https://github.com/gollum/gollum`
2. `cd gollum`
3. `[sudo] bundle install` (may not always be necessary).
4. `bundle exec bin/gollum`
	* Like that, gollum assumes the target wiki (git repository) is the project repository itself. If it's not, execute `bundle exec bin/gollum <path-to-wiki>` instead.
5. Open `http://localhost:4567` in your browser.

### Rack

Gollum can also be ran with any [rack-compatible web server](https://github.com/rack/rack#supported-web-servers). More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack).

### Rack, with an authentication server

Gollum can also be ran alongside a CAS (Central Authentication Service) SSO (single sign-on) server. With a bit of tweaking, this adds basic user-support to Gollum. To see an example and an explanation, navigate [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack-and-CAS-SSO).

### Docker

Gollum can also be ran via [Docker](https://www.docker.com/). More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Docker).

### Service

Gollum can also be ran as a service. More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-as-a-service).

## CONFIGURATION

Gollum comes with the following command line options:

| Option            | Arguments | Description |
| ----------------- | --------- | ----------- |
| --host            | [HOST]    | Specify the hostname or IP address to listen on. Default: `0.0.0.0`.<sup>1</sup> |
| --port            | [PORT]    | Specify the port to bind Gollum with. Default: `4567`. |
| --config          | [FILE]  | Specify path to Gollum's configuration file. |
| --ref             | [REF]     | Specify the git branch to serve. Default: `master`. |
| --adapter         | [ADAPTER] | Launch Gollum using a specific git adapter. Default: `grit`.<sup>2</sup> |
| --bare            | none      | Tell Gollum that the git repository should be treated as bare. This is only necessary when using the default grit adapter. |
| --base-path       | [PATH]    | Specify the leading portion of all Gollum URLs (path info). Setting this to `/wiki` will make the wiki accessible under `http://localhost:4567/wiki/`. Default: `/`. |
| --page-file-dir   | [PATH]    | Specify the subdirectory for all pages. If set, Gollum will only serve pages from this directory and its subdirectories. Default: repository root. |
| --css             | none      | Tell Gollum to inject custom CSS into each page. Uses `custom.css` from repository root.<sup>3,5</sup> |
| --js              | none      | Tell Gollum to inject custom JS into each page. Uses `custom.js` from repository root.<sup>3,5</sup> |
| --emoji           | none      | Parse and interpret emoji tags (e.g. `:heart:`) except when the leading colon is backslashed (e.g. `\:heart:`). |
| --no-edit         | none      | Disable the feature of editing pages. |
| --live-preview    | none      | Enable the live preview feature in page editor. |
| --no-live-preview | none      | Disable the live preview feature in page editor. |
| --allow-uploads   | [MODE]    | Enable file uploads. If set to `dir`, Gollum will store all uploads in the `/uploads/` directory in repository root. If set to `page`, Gollum will store each upload at the currently edited page.<sup>4</sup> |
| --mathjax         | none      | Enables MathJax (renders mathematical equations). By default, uses the `TeX-AMS-MML_HTMLorMML` config with the `autoload-all` extension.<sup>5</sup> |
| --irb             | none      | Launch Gollum in "console mode", with a [predefined API](https://github.com/gollum/gollum-lib/). |
| --h1-title        | none      | Tell Gollum to use the first `<h1>` as page title. |
| --no-display-metadata | none  | Do not render metadata tables in pages. |
| --show-all        | none      | Tell Gollum to also show files in the file view. By default, only valid pages are shown. |
| --collapse-tree   | none      | Tell Gollum to collapse the file tree, when the file view is opened. By default, the tree is expanded. |
| --user-icons      | [MODE]    | Tell Gollum to use specific user icons for history view. Can be set to `gravatar`, `identicon` or `none`. Default: `none`. |
| --mathjax-config  | [FILE]    | Specify path to a custom MathJax configuration. If not specified, uses the `mathjax.config.js` file from repository root. |
| --template-dir    | [PATH]    | Specify custom mustache template directory. |
| --help            | none      | Display the list of options on the command line. |
| --version         | none      | Display the current version of Gollum. |
| --template-page   | none      | Tell Gollum to use /_Template as the default content for new pages. _Template must be git committed. |

**Notes:**

1. The `0.0.0.0` IP address allows remote access. Should you wish for Gollum to turn into a personal Wiki, use `127.0.0.1`.
2. Before using `--adapter`, you should probably read [this](https://github.com/gollum/gollum/wiki/Git-adapters) first.
3. When `--css` or `--js` is used, respective files must be committed to your git repository or you will get a 302 redirect to the create a page.
4. Files can be uploaded simply by dragging and dropping them onto the editor's text area (this is, however exclusive to the default editor, not the live preview editor).
5. Read the relevant [Security note](https://github.com/gollum/gollum/wiki/Security#custom-cssjs--mathjax-config) before using these.

### Config file

When `--config` option is used, certain inner parts of Gollum can be customized. This is used throughout our wiki for certain user-level alterations, among which [customizing supported markups](https://github.com/gollum/gollum/wiki/Formats-and-extensions) will probably stand out.

**All of the mentioned alterations work both for Gollum's config file (`config.rb`) and Rack's config file (`config.ru`).**
