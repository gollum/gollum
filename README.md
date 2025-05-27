# gollum - A git-based Wiki

[![Gem Version](https://badge.fury.io/rb/gollum.svg)](http://badge.fury.io/rb/gollum)
[![Build Status](https://github.com/gollum/gollum/actions/workflows/test.yaml/badge.svg)](https://github.com/gollum/gollum/actions/workflows/test.yaml)
[![Open Source Helpers](https://www.codetriage.com/gollum/gollum/badges/users.svg)](https://www.codetriage.com/gollum/gollum)
[![Cutting Edge Dependency Status](https://cuttingedge.onrender.com/github/gollum/gollum/svg 'Cutting Edge Dependency Status')](https://cuttingedge.onrender.com/github/gollum/gollum/info)
[![Docker Pulls](https://img.shields.io/docker/pulls/gollumwiki/gollum)](https://hub.docker.com/r/gollumwiki/gollum)
[![License](https://img.shields.io/github/license/gollum/gollum)](https://github.com/gollum/gollum/blob/master/LICENSE)
[![GitHub Contributors](https://img.shields.io/github/contributors/gollum/gollum)](https://github.com/gollum/gollum/graphs/contributors)

Gollum is a simple wiki system built on top of Git. A Gollum Wiki is simply a git repository of a specific nature:

*   A Gollum repository's contents are human-editable text or markup files.
*   Pages may be organized into directories any way you choose.
*   Other content can also be included, for example images, PDFs and headers/footers for your pages.
*   Gollum pages:
    *   May be written in a variety of [markups](#markups).
    *   Can be edited with your favourite editor (changes will be visible after committing) or with the built-in web interface.
    *   Can be displayed in all versions, reverted, etc.
*   Gollum strives to be [compatible](https://github.com/gollum/gollum/wiki/5.0-release-notes#compatibility-option) with [GitHub](https://docs.github.com/en/communities/documenting-your-project-with-wikis/about-wikis) and [GitLab](https://docs.gitlab.com/ee/user/project/wiki/#create-or-edit-wiki-pages-locally) wikis.
    *   Just clone your GitHub/GitLab wiki and view and edit it locally!
*   Gollum supports advanced functionality like:
    *   Diagrams using [Mermaid](https://github.com/gollum/gollum/wiki#mermaid-diagrams) or [PlantUML](https://github.com/gollum/gollum/wiki#plantuml-diagrams)
    *   [BibTeX and Citation support](https://github.com/gollum/gollum/wiki/BibTeX-and-Citations)
    *   Annotations using [CriticMarkup](https://github.com/gollum/gollum/wiki#criticmarkup-annotations)
    *   [Mathematics](https://github.com/gollum/gollum/wiki#mathematics) via KaTeX or MathJax
    *   [Macros](https://github.com/gollum/gollum/wiki/Standard-Macros)
    *   [Redirects](https://github.com/gollum/gollum/wiki#redirects)
    *   [RSS Feed](https://github.com/gollum/gollum/wiki/5.0-release-notes#rss-feed) of latest changes
    *   ...and [more](https://github.com/gollum/gollum/wiki)

See the [wiki](https://github.com/gollum/gollum/wiki) for extensive documentation, along with [screenshots](https://github.com/gollum/gollum/wiki/Screenshots) of Gollum's features.

---

## Table of Contents

- [System Requirements](#system-requirements)
- [Installation](#installation)
  - [As a Ruby Gem](#as-a-ruby-gem)
  - [Via Docker](#via-docker)
  - [As a Web Application Resource (Java)](#as-a-web-application-resource-java)
- [Markups](#markups)
  - [Markdown Flavors](#markdown-flavors)
- [Running Gollum](#running-gollum)
  - [Quick Start from Command Line](#quick-start-from-command-line)
  - [Running From Source](#running-from-source)
  - [Running with Rack](#running-with-rack)
  - [Running with an Authentication Server](#running-with-an-authentication-server)
  - [Running as a Service](#running-as-a-service)
- [Environment](#environment)
- [Configuration](#configuration)
  - [Command-Line Options](#command-line-options)
  - [Config File](#config-file)
- [Contributing](#contributing)

---

## System Requirements

Gollum runs both on Unix-like systems and on Windows.

Gollum runs either using 'normal' Ruby (MRI) or [JRuby](https://github.com/jruby/jruby) (Ruby on the Java Virtual Machine). On Windows, Gollum runs only using JRuby (either from source, or [prebuilt](#as-a-web-application-resource-java)).

On MRI, Gollum uses the [rugged](https://github.com/libgit2/rugged) git library, while on JRuby/Java it utilizes the [rjgit](https://github.com/repotag/rjgit) and [JGit](https://eclipse.dev/jgit/) libraries. See [here](https://github.com/gollum/gollum/wiki/Git-adapters) for more info.

## Installation

### As a Ruby Gem

Ruby is best installed either via [RVM](https://rvm.io/) or a package manager of choice. Then simply:

```bash
gem install gollum
```

Installation examples for individual systems can be seen [here](https://github.com/gollum/gollum/wiki/Installation).

### Via Docker

See [here](https://github.com/gollum/gollum/wiki/Gollum-via-Docker) for instructions on how to run Gollum via Docker.

### As a Web Application Resource (Java)

The [latest Release](https://github.com/gollum/gollum/releases/) of Gollum will always contain a downloadable `gollum.war` file that can be directly executed on any system with a working Java installation:

```bash
java -jar gollum.war -S gollum <your-gollum-arguments-here>
```

When using the `.war`, please be sure to pass [absolute paths](https://github.com/gollum/gollum/wiki/Gollum-via-Java-WAR#absolute-paths-issue) to your Gollum arguments.

## Markups

Gollum allows using different markup languages on different wiki pages. It presently ships with support for the following markups:

*   [Markdown](http://daringfireball.net/projects/markdown/syntax) (see [below](#markdown-flavors) for more information on Markdown flavors)
*   [RDoc](http://rdoc.sourceforge.net/)

You can easily activate support for other markups by installing additional renderers (any that are supported by [github-markup](https://github.com/github/markup)):

*   [AsciiDoc](http://asciidoctor.org/docs/asciidoc-syntax-quick-reference/) -- `gem install asciidoctor`
*   [Creole](http://www.wikicreole.org/wiki/CheatSheet) -- `gem install creole`
*   [MediaWiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`
*   [Org](http://orgmode.org/worg/dev/org-syntax.html) -- `gem install org-ruby`
*   [Pod](http://perldoc.perl.org/perlpod.html) -- requires Perl >= 5.10 (the `perl` command must be available on your command line)
    *   Lower versions should install `Pod::Simple` from CPAN.
*   [ReStructuredText](http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html) -- requires python >= 3
    *   Note that Gollum will also need you to install `docutils` for python
*   [Textile](http://redcloth.org/hobix.com/textile/quick.html) -- `gem install RedCloth`

### Markdown Flavors

By default, Gollum ships with the `kramdown` gem to render Markdown. However, you can use any [Markdown renderer supported by github-markup](https://github.com/github/markup/blob/master/lib/github/markup/markdown.rb). This includes [CommonMark](https://commonmark.org/) support via the `commonmarker` gem. The first installed renderer from the list will be used (e.g., `redcarpet` will NOT be used if `github/markdown` is installed). Just `gem install` the renderer of your choice.

See [here](https://github.com/gollum/gollum/wiki/Custom-rendering-gems) for instructions on how to use custom rendering gems and set custom options.

## Running Gollum

### Quick Start from Command Line

1.  Run: `gollum /path/to/wiki` where `/path/to/wiki` is an initialized Git repository.
2.  Open `http://localhost:4567` in your browser.

### Running From Source

1.  `git clone https://github.com/gollum/gollum`
2.  `cd gollum`
3.  `bundle install` (may require `sudo` depending on your Ruby setup)
4.  `bundle exec bin/gollum`
5.  Open `http://localhost:4567` in your browser.

### Running with Rack

Gollum can also be run with any [rack-compatible web server](https://github.com/rack/rack#supported-web-servers). More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack).

### Running with an Authentication Server

Gollum can also be run alongside a CAS (Central Authentication Service) SSO (single sign-on) server. With a bit of tweaking, this adds basic user-support to Gollum. To see an example and an explanation, navigate [over here](https://github.com/gollum/gollum/wiki/Gollum-via-Rack-and-CAS-SSO).

### Running as a Service

Gollum can also be run as a service. More on that [over here](https://github.com/gollum/gollum/wiki/Gollum-as-a-service).

## Environment

Gollum uses the environment variable `APP_ENV` primarily to control how the underlying Sinatra app behaves:

*   `development` – reload the app on every request
*   `production` – load the app only once

## Configuration

Gollum comes with the command line options listed below. Note that there are some additional 'minor' options to tweak Gollum's behaviour that do not have commandline options, but can be configured in [config.rb](#config-file).

### Command-Line Options

| Option                  | Arguments           | Description                                                                                                                                                               |
| ----------------------- | ------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `--host`                | `[HOST]`            | Specify the hostname or IP address to listen on. Default: '0.0.0.0'. (Note: `0.0.0.0` allows remote access. For a personal Wiki, use `127.0.0.1`.)                   |
| `--port`                | `[PORT]`            | Specify the port to bind Gollum with. Default: `4567`.                                                                                                                      |
| `--config`              | `[FILE]`            | Specify path to Gollum's [configuration file](#config-file).                                                                                                             |
| `--ref`                 | `[REF]`             | Specify the git branch to serve. Default: `main` (or `master` if `main` is not found).                                                                                                    |
| `--bare`                |                     | Tell Gollum that the git repository should be treated as bare.                                                                                                          |
| `--adapter`             | `[ADAPTER]`         | Launch Gollum using a specific git adapter. Default: `rugged`. (See [Git Adapters](https://github.com/gollum/gollum/wiki/Git-adapters) for more info.)                 |
| `--base-path`           | `[PATH]`            | Specify the leading portion of all Gollum URLs (path info). Setting this to `/wiki` will make the wiki accessible under `http://localhost:4567/wiki/`. Default: `/`.     |
| `--page-file-dir`       | `[PATH]`            | Specify the subdirectory for all pages. If set, Gollum will only serve pages from this directory and its subdirectories. Default: repository root.                        |
| `--static`, `--no-static` |                   | Use static assets. Defaults to `false` in development/test, `true` in production/staging.                                                                                    |
| `--assets`              | `[PATH]`            | Set the path to look for static assets.                                                                                                                                   |
| `--css`                 |                     | Tell Gollum to inject custom CSS into each page. Uses `custom.css` from wiki root (must be committed).                                                                    |
| `--js`                  |                     | Tell Gollum to inject custom JS into each page. Uses `custom.js` from wiki root (must be committed).                                                                     |
| `--no-edit`             |                     | Disable the feature of editing pages.                                                                                                                                     |
| `--allow-uploads`       | `[MODE]`            | Enable file uploads. If set to `dir`, Gollum will store all uploads in the `/uploads/` directory in repository root. If set to `page`, Gollum will store each upload at the currently edited page. (Files can be uploaded by dragging and dropping onto the editor's text area.) |
| `--math`                | `[RENDERER]`        | Enable rendering of mathematical equations. Valid renderers: `mathjax`, `katex`. Default: `katex`. Add custom configuration for the renderer to `math.config.js` and commit it to the repo. |
| `--critic-markup`       |                     | Enable support for annotations using [CriticMarkup](http://criticmarkup.com/).                                                                                           |
| `--irb`                 |                     | Launch Gollum in "console mode", with a [predefined API](https://github.com/gollum/gollum-lib/).                                                                          |
| `--h1-title`            |                     | Tell Gollum to use the first `<h1>` as page title.                                                                                                                      |
| `--no-display-metadata` |                     | Do not render metadata tables in pages.                                                                                                                                   |
| `--user-icons`          | `[MODE]`            | Tell Gollum to use specific user icons for history view. Can be set to `gravatar`, `identicon` or `none`. Default: `none`.                                                  |
| `--template-dir`        | `[PATH]`            | Specify custom mustache template directory. Only overrides templates that exist in this directory.                                                                      |
| `--template-page`       |                     | Use `_Template` in root as a template for new pages. Must be committed.                                                                                                   |
| `--emoji`               |                     | Parse and interpret emoji tags (e.g. `:heart:`) except when the leading colon is backslashed (e.g. `\:heart:`).                                                           |
| `--lenient-tag-lookup`  |                     | Internal links resolve case-insensitively, will treat spaces as hyphens, and will match the first page found with a certain filename, anywhere in the repository. Provides compatibility with Gollum 4.x. |
| `--help`                |                     | Display the list of options on the command line.                                                                                                                          |
| `--version`             |                     | Display the current version of Gollum.                                                                                                                                    |
| `--versions`            |                     | Display the current version of Gollum and auxiliary gems.                                                                                                                 |

### Config File

When the `--config` option is used, certain inner parts of Gollum can be customized. This is used throughout our wiki for certain user-level alterations, among which [customizing supported markups](https://github.com/gollum/gollum/wiki/Formats-and-extensions) will probably stand out.

See [here](https://github.com/gollum/gollum/wiki/Sample-config.rb) for documentation about settings configurable in `config.rb`.

All of the mentioned alterations and options work both for Gollum's config file (`config.rb`) and Rack's config file (`config.ru`).

## Contributing

Please consider helping out! See [CONTRIBUTING.md](CONTRIBUTING.md) for information on how to submit issues, and how to start hacking on gollum.
