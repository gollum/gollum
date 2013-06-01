gollum -- A wiki built on top of Git
====================================

[![Gem Version](https://badge.fury.io/rb/gollum.png)](http://rubygems.org/gems/gollum)
[![Build Status](https://secure.travis-ci.org/gollum/gollum.png?branch=master)](http://travis-ci.org/gollum/gollum)
[![Dependency Status](https://gemnasium.com/gollum/gollum.png)](https://gemnasium.com/gollum/gollum)

## DESCRIPTION

Gollum is a simple wiki system built on top of Git that powers GitHub Wikis.

Gollum wikis are simply Git repositories that adhere to a specific format.
Gollum pages may be written in a variety of formats and can be edited in a
number of ways depending on your needs. You can edit your wiki locally:

* With your favorite text editor or IDE (changes will be visible after committing).
* With the built-in web interface.
* With the Gollum Ruby API.

Gollum follows the rules of [Semantic Versioning](http://semver.org/) and uses
[TomDoc](http://tomdoc.org/) for inline documentation.

## SYSTEM REQUIREMENTS

- Python 2.5+ (2.7.3 recommended)
- Ruby 1.8.7+ (1.9.3 recommended)
- Unix like operating system (OS X, Ubuntu, Debian, and more)
- Will not work on Windows (because of [grit](https://github.com/github/grit))

## SECURITY

Don't enable `--custom-css` or `--custom-js` unless you trust every user who has the ability to edit the wiki.
A better solution with more security is being tracked in [#665](https://github.com/gollum/gollum/issues/665).

## INSTALLATION

The best way to install Gollum is with RubyGems:

```bash
$ [sudo] gem install gollum
```

If you're installing from source, you can use [Bundler][bundler] to pick up all the
gems:

```bash
$ bundle install
```

In order to use the various formats that Gollum supports, you will need to
separately install the necessary dependencies for each format. You only need
to install the dependencies for the formats that you plan to use.

* [ASCIIDoc](http://www.methods.co.nz/asciidoc/) -- `brew install asciidoc` on mac or `apt-get install -y asciidoc` on Ubuntu
* [Creole](http://wikicreole.org/) -- `gem install creole`
* [Markdown](http://daringfireball.net/projects/markdown/) -- `gem install redcarpet`
* [GitHub Flavored Markdown](https://help.github.com/articles/github-flavored-markdown) -- `gem install github-markdown`
* [Org](http://orgmode.org/) -- `gem install org-ruby`
* [Pod](http://search.cpan.org/dist/perl/pod/perlpod.pod) -- `Pod::Simple::HTML` comes with Perl >= 5.10. Lower versions should install Pod::Simple from CPAN.
* [RDoc](http://rdoc.sourceforge.net/)
* [ReStructuredText](http://docutils.sourceforge.net/rst.html) -- `easy_install docutils`
* [Textile](http://www.textism.com/tools/textile/) -- `gem install RedCloth`
* [MediaWiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`

[bundler]: http://gembundler.com/


## SYNTAX

Gollum supports a variety of formats and extensions (Markdown, MediaWiki, Textile, …).
On top of these formats Gollum lets you insert headers, footers, links, image, math and more.

Check out the [Gollum Wiki](https://github.com/gollum/gollum/wiki) for all of Gollum's formats and syntactic options.


## RUNNING

To view and edit your Gollum repository locally via the built in web
interface, simply install the Gollum gem, navigate to your repository via the
command line, and run the executable:

```bash
$ gollum
```

This will start up a web server running the Gollum frontend and you can view
and edit your wiki at http://localhost:4567. To get help on the command line
utility, you can run it like so:

```bash
$ gollum --help
```

Note that the gollum server will not run on Windows because of [an issue](https://github.com/rtomayko/posix-spawn/issues/9) with posix-spawn (which is used by Grit).

### RACK

You can also run gollum with any rack-compatible server by placing this config.ru
file inside your wiki repository. This allows you to utilize any Rack middleware
like Rack::Auth, OmniAuth, etc.

```ruby
#!/usr/bin/env ruby
require 'rubygems'
require 'gollum/app'

gollum_path = File.expand_path(File.dirname(__FILE__)) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
Precious::App.set(:gollum_path, gollum_path)
Precious::App.set(:default_markup, :markdown) # set your favorite markup language
Precious::App.set(:wiki_options, {:universal_toc => false})
run Precious::App
```

Your Rack middleware can pass author details to Gollum in a Hash in the session under the 'gollum.author' key.

## CONFIG FILE

Gollum optionally takes a `--config file`. See [config.rb](https://github.com/gollum/gollum/blob/master/config.rb) for an example.

## CUSTOM CSS/JS

The `--css` flag will inject `custom.css` from the root of your git repository into each page. `custom.css` must be commited to git or you will get a 302 redirect to the create page.

The `--js` flag will inject `custom.js` from the root of your git repository into each page. `custom.js` must be commited to git or you will get a 302 redirect to the create page.


## API DOCUMENTATION

The [Gollum API](https://github.com/gollum/gollum-lib/) allows you to retrieve
raw or formatted wiki content from a Git repository, write new content to the
repository, and collect various meta data about the wiki as a whole.


## CONTRIBUTE

If you'd like to hack on Gollum, start by forking the repo on GitHub:

http://github.com/gollum/gollum

To get all of the dependencies, install the gem first. The best way to get
your changes merged back into core is as follows:

1. Clone down your fork
1. Create a thoughtfully named topic branch to contain your change
1. Hack away
1. Add tests and make sure everything still passes by running `rake`
1. If you are adding new functionality, document it in the README
1. Do not change the version number, I will do that on my end
1. If necessary, rebase your commits into logical chunks, without errors
1. Push the branch up to GitHub
1. Send a pull request to the gollum/gollum project.

## RELEASING

Gollum uses [Semantic Versioning](http://semver.org/).

    x.y.z

For z releases:

```bash
$ rake bump
$ rake release
```

For x.y releases:

```bash
Update VERSION in lib/gollum.rb
$ rake gemspec
$ rake release
```

## BUILDING THE GEM FROM MASTER

```bash
$ gem uninstall -aIx gollum
$ git clone https://github.com/gollum/gollum.git
$ cd gollum
gollum$ rake build
gollum$ gem install --no-ri --no-rdoc pkg/gollum*.gem
```

## RUN THE TESTS

```bash
$ bundle install
$ bundle exec rake test
```

## WORK WITH TEST REPOS

An example of how to add a test file to the bare repository lotr.git.

```bash
$ mkdir tmp; cd tmp
$ git clone ../lotr.git/ .
Cloning into '.'...
done.
$ git log
$ echo "test" > test.md
$ git add . ; git commit -am "Add test"
$ git push ../lotr.git/ master
```
