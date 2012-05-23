gollum -- A wiki built on top of Git
====================================

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


## INSTALLATION

The best way to install Gollum is with RubyGems:

    $ [sudo] gem install gollum

If you're installing from source, you can use [Bundler][bundler] to pick up all the
gems:

    $ bundle install

In order to use the various formats that Gollum supports, you will need to
separately install the necessary dependencies for each format. You only need
to install the dependencies for the formats that you plan to use.

* [ASCIIDoc](http://www.methods.co.nz/asciidoc/) -- `brew install asciidoc` on mac or `apt-get install -y asciidoc` on Ubuntu
* [Creole](http://wikicreole.org/) -- `gem install creole`
* [Markdown](http://daringfireball.net/projects/markdown/) -- `gem install redcarpet`
* [GitHub Flavored Markdown](http://github.github.com/github-flavored-markdown/) -- `gem install github-markdown`
* [Org](http://orgmode.org/) -- `gem install org-ruby`
* [Pod](http://search.cpan.org/dist/perl/pod/perlpod.pod) -- `Pod::Simple::HTML` comes with Perl >= 5.10. Lower versions should install Pod::Simple from CPAN.
* [RDoc](http://rdoc.sourceforge.net/)
* [ReStructuredText](http://docutils.sourceforge.net/rst.html) -- `easy_install docutils`
* [Textile](http://www.textism.com/tools/textile/) -- `gem install RedCloth`
* [MediaWiki](http://www.mediawiki.org/wiki/Help:Formatting) -- `gem install wikicloth`

[bundler]: http://gembundler.com/

## RUNNING

To view and edit your Gollum repository locally via the built in web
interface, simply install the Gollum gem, navigate to your repository via the
command line, and run the executable:

    $ gollum

This will start up a web server running the Gollum frontend and you can view
and edit your wiki at http://localhost:4567. To get help on the command line
utility, you can run it like so:

    $ gollum --help

Note that the gollum server will not run on Windows because of [an issue](https://github.com/rtomayko/posix-spawn/issues/9) with posix-spawn (which is used by Grit).

## REPO STRUCTURE

A Gollum repository's contents are designed to be human editable. Page content
is written in `page files` and may be organized into directories any way you
choose. Special footers can be created in `footer files`. Other content
(images, PDFs, etc) may also be present and organized in the same way.


## PAGE FILES

Page files may be written in any format supported by
[GitHub-Markup](http://github.com/github/markup) (except roff). The
current list of formats and allowed extensions is:

* ASCIIDoc: .asciidoc
* Creole: .creole
* Markdown: .markdown, .mdown, .mkdn, .mkd, .md
* Org Mode: .org
* Pod: .pod
* RDoc: .rdoc
* ReStructuredText: .rest.txt, .rst.txt, .rest, .rst
* Textile: .textile
* MediaWiki: .mediawiki, .wiki

Gollum detects the page file format via the extension, so files must have one
of the supported extensions in order to be converted.

Page file names may contain any printable UTF-8 character except space
(U+0020) and forward slash (U+002F). If you commit a page file with any of
these characters in the name it will not be accessible via the web interface.

Even though page files may be placed in any directory, there is still only a
single namespace for page names, so all page files should have globally unique
names regardless of where they are located in the repository.

The special page file `Home.ext` (where the extension is one of the supported
formats) will be used as the entrance page to your wiki. If it is missing, an
automatically generated table of contents will be shown instead.

## SIDEBAR FILES

Sidebar files allow you to add a simple sidebar to your wiki.  Sidebar files
are named `_Sidebar.ext` where the extension is one of the supported formats.
Sidebars affect all pages in their directory and any subdirectories that do not
have a sidebar file of their own.

## HEADER FILES

Header files allow you to add a simple header to your wiki. Header files must
be named `_Header.ext` where the extension is one of the supported formats.
Like sidebars, headers affect all pages in their directory and any
subdirectories that do not have a header file of their own.

## FOOTER FILES

Footer files allow you to add a simple footer to your wiki. Footer files must
be named `_Footer.ext` where the extension is one of the supported formats.
Like sidebars, footers affect all pages in their directory and any
subdirectories that do not have a footer file of their own.

## HTML SANITIZATION

For security and compatibility reasons Gollum wikis may not contain custom CSS
or JavaScript. These tags will be stripped from the converted HTML. See
`docs/sanitization.md` for more details on what tags and attributes are
allowed.


## BRACKET TAGS

A variety of Gollum tags use a double bracket syntax. For example:

    [[Link]]

Some tags will accept attributes which are separated by pipe symbols. For
example:

    [[Link|Page Title]]

In all cases, the first thing in the link is what is displayed on the page.
So, if the tag is an internal wiki link, the first thing in the tag will be
the link text displayed on the page. If the tag is an embedded image, the
first thing in the tag will be a path to an image file. Use this trick to
easily remember which order things should appear in tags.

Some formats, such as MediaWiki, support the opposite syntax:

    [[Page Title|Link]]

## PAGE LINKS

To link to another Gollum wiki page, use the Gollum Page Link Tag.

    [[Frodo Baggins]]

The above tag will create a link to the corresponding page file named
`Frodo-Baggins.ext` where `ext` may be any of the allowed extension types. The
conversion is as follows:

  1. Replace any spaces (U+0020) with dashes (U+002D)
  2. Replace any slashes (U+002F) with dashes (U+002D)

If you'd like the link text to be something that doesn't map directly to the
page name, you can specify the actual page name after a pipe:

    [[Frodo|Frodo Baggins]]

The above tag will link to `Frodo-Baggins.ext` using "Frodo" as the link text.

The page file may exist anywhere in the directory structure of the repository.
Gollum does a breadth first search and uses the first match that it finds.

Here are a few more examples:

    [[J. R. R. Tolkien]] -> J.-R.-R.-Tolkien.ext
    [[Movies / The Hobbit]] -> Movies---The-Hobbit.ext
    [[モルドール]] -> モルドール.ext


## EXTERNAL LINKS

As a convenience, simple external links can be placed within brackets and they
will be linked to the given URL with the URL as the link text. For example:

    [[http://example.com]]

External links must begin with either "http://" or "https://". If you need
something more flexible, you can resort to the link syntax in the page's
underlying markup format.


## ABSOLUTE VS. RELATIVE VS. EXTERNAL PATH

For Gollum tags that operate on static files (images, PDFs, etc), the paths
may be referenced as either relative, absolute, or external. Relative paths
point to a static file relative to the page file within the directory
structure of the Gollum repo (even though after conversion, all page files
appear to be top level). These paths are NOT prefixed with a slash. For
example:

    gollum.pdf
    docs/diagram.png

Absolute paths point to a static file relative to the Gollum repo's
root, regardless of where the page file is stored within the directory
structure. These paths ARE prefixed with a slash. For example:

    /pdfs/gollum.pdf
    /docs/diagram.png

External paths are full URLs. An external path must begin with either
"http://" or "https://". For example:

    http://example.com/pdfs/gollum.pdf
    http://example.com/images/diagram.png

All of the examples in this README use relative paths, but you may use
whatever works best in your situation.


## FILE LINKS

To link to static files that are contained in the Gollum repository you should
use the Gollum File Link Tag.

    [[Gollum|gollum.pdf]]

The first part of the tag is the link text. The path to the file appears after
the pipe.


## IMAGES

To display images that are contained in the Gollum repository you should use
the Gollum Image Tag. This will display the actual image on the page.

    [[gollum.png]]

In addition to the simple format, there are a variety of options that you
can specify between pipe delimiters.

To specify alt text, use the `alt=` option. Default is no alt text.

    [[gollum.png|alt=Gollum and his precious wiki]]

To place the image in a frame, use the `frame` option. When combined with the
`alt=` option, the alt text will be used as a caption as well. Default is no
frame.

    [[gollum.png|frame|alt=Gollum and his precious wiki]]

To specify the alignment of the image on the page, use the `align=` option.
Possible values are `left`, `center`, and `right`. Default is `left`.

    [[gollum.png|align=center]]

To float an image so that text flows around it, use the `float` option. When
`float` is specified, only `left` and `right` are valid `align` options.
Default is not floating. When floating is activated but no alignment is
specified, default alignment is `left`.

    [[gollum.png|float]]

To specify a max-width, use the `width=` option. Units must be specified in
either `px` or `em`.

    [[gollum.png|width=400px]]

To specify a max-height, use the `height=` option. Units must be specified in
either `px` or `em`.

    [[gollum.png|height=300px]]

Any of these options may be composed together by simply separating them with
pipes.


## ESCAPING GOLLUM TAGS

If you need the literal text of a wiki or static link to show up in your final
wiki page, simply preface the link with a single quote (like in LISP):

    '[[Page Link]]
    '[[File Link|file.pdf]]
    '[[image.jpg]]

This is useful for writing about the link syntax in your wiki pages.

## TABLE OF CONTENTS

Gollum has a special tag to insert a table of contents (new in v2.1)

    '[[_TOC_]]

This tag is case sensitive, use all upper case.  The TOC tag can be inserted
into the `_Header`, `_Footer` or `_Sidebar` files too.

There is also a wiki option `:universal_toc` which will display a
table of contents at the top of all your wiki pages if it is enabled.
The `:universal_toc` is not enabled by default.  To set the option,
add the option to the `:wiki_options` hash before starting the
frontend app:

    Precious::App.set(:wiki_options, {:universal_toc => true})

## SYNTAX HIGHLIGHTING

In page files you can get automatic syntax highlighting for a wide range of
languages (courtesy of [Pygments](http://pygments.org/) - must install
separately) by using the following syntax:

    ```ruby
      def foo
        puts 'bar'
      end
    ```

The block must start with three backticks, at the beginning of a line or
indented with any number of spaces or tabs.
After that comes the name of the language that is contained by the
block. The language must be one of the `short name` lexer strings supported by
Pygments. See the [list of lexers](http://pygments.org/docs/lexers/) for valid
options.

The block contents should be indented at the same level than the opening backticks.
If the block contents are indented with an additional two spaces or one tab,
then that whitespace will be ignored (this makes the blocks easier to read in plaintext).

The block must end with three backticks indented at the same level than the opening
backticks.

## MATHEMATICAL EQUATIONS


Page files may contain mathematic equations in TeX syntax that will be nicely
typeset into the expected output. A block-style equation is delimited by `\[`
and `\]`. For example:

    \[ P(E) = {n \choose k} p^k (1-p)^{ n-k} \]

Inline equations are delimited by `\(` and `\)`. These equations will appear
inline with regular text. For example:

    The Pythagorean theorem is \( a^2 + b^2 = c^2 \).

### INSTALLATION REQUIREMENTS

In order to get the mathematical equations rendering to work, you need the following binaries:

* LaText, TeTex or MacTex/BasicTeX (latex, dvips)
* ImageMagick (convert)
* Ghostscript (gs)

## SEQUENCE DIAGRAMS

You may imbed sequence diagrams into your wiki page (rendered by
[WebSequenceDiagrams](http://www.websequencediagrams.com) by using the
following syntax:

    {{{ blue-modern
      alice->bob: Test
      bob->alice: Test response
    }}}

You can replace the string "blue-modern" with any supported style.

## API DOCUMENTATION

The Gollum API allows you to retrieve raw or formatted wiki content from a Git
repository, write new content to the repository, and collect various meta data
about the wiki as a whole.

Initialize the Gollum::Repo object:

    # Require rubygems if necessary
    require 'rubygems'

    # Require the Gollum library
    require 'gollum'

    # Create a new Gollum::Wiki object by initializing it with the path to the
    # Git repository.
    wiki = Gollum::Wiki.new("my-gollum-repo.git")
    # => <Gollum::Wiki>

By default, internal wiki links are all absolute from the root. To specify a different base path, you can specify the `:base_path` option:

    wiki = Gollum::Wiki.new("my-gollum-repo.git", :base_path => "/wiki")

Get the latest version of the given human or canonical page name:

    page = wiki.page('page-name')
    # => <Gollum::Page>

    page.raw_data
    # => "# My wiki page"

    page.formatted_data
    # => "<h1>My wiki page</h1>"

    page.format
    # => :markdown

    vsn = page.version
    # => <Grit::Commit>

    vsn.id
    # => '3ca43e12377ea1e32ea5c9ce5992ec8bf266e3e5'

Get the footer (if any) for a given page:

    page.footer
    # => <Gollum::Page>

Get a list of versions for a given page:

    vsns = wiki.page('page-name').versions
    # => [<Grit::Commit, <Grit::Commit, <Grit::Commit>]

    vsns.first.id
    # => '3ca43e12377ea1e32ea5c9ce5992ec8bf266e3e5'

    vsns.first.authored_date
    # => Sun Mar 28 19:11:21 -0700 2010

Get a specific version of a given canonical page file:

    wiki.page('page-name', '5ec521178e0eec4dc39741a8978a2ba6616d0f0a')

Get the latest version of a given static file:

    file = wiki.file('asset.js')
    # => <Gollum::File>

    file.raw_data
    # => "alert('hello');"

    file.version
    # => <Grit::Commit>

Get a specific version of a given static file:

    wiki.file('asset.js', '5ec521178e0eec4dc39741a8978a2ba6616d0f0a')

Get an in-memory Page preview (useful for generating previews for web
interfaces):

    preview = wiki.preview_page("My Page", "# Contents", :markdown)
    preview.formatted_data
    # => "<h1>Contents</h1>"

Methods that write to the repository require a Hash of commit data that takes
the following form:

    commit = { :message => 'commit message',
               :name => 'Tom Preston-Werner',
               :email => 'tom@github.com' }

Write a new version of a page (the file will be created if it does not already
exist) and commit the change. The file will be written at the repo root.

    wiki.write_page('Page Name', :markdown, 'Page contents', commit)

Update an existing page. If the format is different than the page's current
format, the file name will be changed to reflect the new format.

    page = wiki.page('Page Name')
    wiki.update_page(page, page.name, page.format, 'Page contents', commit)

To delete a page and commit the change:

    wiki.delete_page(page, commit)

### RACK

You can also run gollum with any rack-compatible server by placing this config.ru
file inside your wiki repository. This allows you to utilize any Rack middleware
like Rack::Auth, OmniAuth, etc.

    #!/usr/bin/env ruby
    require 'rubygems'
    require 'gollum/frontend/app'

    gollum_path = File.expand_path(File.dirname(__FILE__)) # CHANGE THIS TO POINT TO YOUR OWN WIKI REPO
    Precious::App.set(:gollum_path, gollum_path)
    Precious::App.set(:default_markup, :markdown) # set your favorite markup language
    Precious::App.set(:wiki_options, {:universal_toc => false})
    run Precious::App

## Windows Filename Validation
Note that filenames on windows must not contain any of the following characters `\ / : * ? " < > |`. See [this support article](http://support.microsoft.com/kb/177506) for details.

## Testing

[![Build Status](https://secure.travis-ci.org/github/gollum.png?branch=master)](http://travis-ci.org/github/gollum)

## CONTRIBUTE

If you'd like to hack on Gollum, start by forking my repo on GitHub:

http://github.com/github/gollum

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
1. Send a pull request to the github/gollum project.

## RELEASING

    $ rake gemspec
    $ gem build gollum.gemspec
    $ gem push gollum-X.Y.Z.gem
