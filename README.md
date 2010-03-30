gollum -- A wiki built on top of Git
====================================

## DESCRIPTION

Gollum is a simple wiki built on top of Git that powers GitHub Wikis. Gollum
is designed so that you can create a compliant Git repository (known as a
Gollum repository) either by hand, by calling API methods, or via the web
interface.

We are making the source available so that you may test your wikis locally if
you choose to edit them by hand.


## REPO STRUCTURE

A Gollum repository's contents are designed to be human editable. Page content
is written in `page files` and may be organized into directories any way you
choose. Other content (images, CSS, JavaScript, PDFs, etc) may also be
present and organized in the same way.

Page files may be written in formats that render to HTML. Currently supported
formats are Markdown and Textile. They must have the proper file extension
that corresponds to the format of the content:

  * Markdown: .markdown, .mkdn, .md
  * Textile: .textile

Even though page files may be placed in any directory, there is still only a
single namespace for page names, so all page files should have globally unique
names regardless of where there are located in the repository.


## WIKI LINKS

Wiki links in Gollum are processed before page content is converted into HTML.
They take the following form:

    [[Page Name]]

If you'd like the link text to be something other than the page name, you can
use the advanced form:

    [[Page Name | Alternate Text]]

The above wiki links will create a link to the corresponding page file named
`page-name.ext` where `ext` may be any of the allowed extension types. The
conversion is as follows:

  1. Replace any non-alpha characters with a dash
  2. Lowercase all alpha characters

Here are a few more examples:

    [[Tom "TPW" Preston-Werner]] -> tom--tpw--preston-werner.ext
    [[Quantum Physics | quantum]] -> quantum-physics.ext

The page file may exist anywhere in the directory structure of the repository.
Gollum does a breadth first search and uses the first match that it finds.

## STATIC LINKS

To link to static files that are contained in the Gollum repository you should
use the static link tag. Because this tag produces a URL instead of a full
link tag, it is contained within single brackets. It uses the `file:`
identifier to mark the contents as a static file reference. Static links are
processed before page content is converted into HTML.

You can use either absolute or relative paths to specify the file location.
Absolute paths (that start with a slash) are bound to the repository root.

    [file:/gollum.pdf]
    [file:/docs/gollum.pdf]

Relative paths (without a beginning slash) are referenced from the location of
the page file. For example, if your page file is `documentation.md` and is
stored in the `docs` directory under the repository root, then the following
link in `documentation.md` will produce a URL to `/docs/gollum.pdf`:

    [file:gollum.pdf]

In Markdown, a link would take the following form:

    [Gollum Manual]([file:gollum.pdf])

In Textile, it would look like this:

    "Gollum Manual":[file:gollum.pdf]

And in HTML, like so:

    <img src="[file:gollum.pdf]" alt="Gollum Manual" />


## ESCAPING WIKI AND STATIC LINKS

If you need the literal text of a wiki or static link to show up in your final
wiki page, simply preface the link with a single quote (like in LISP):

    '[[Wiki Link]]
    '[file:foo.jpg]

This is useful for writing about the link syntax in your wiki pages.


## SYNTAX HIGHLIGHTING

In Markdown and Textile page files you can get automatic syntax highlighting
for a wide range of languages (courtesy of Pygments) by using the following
syntax:

    ```ruby```
      def foo
        puts 'bar'
      end
    ```

The block must start with three backticks (as the first characters on the
line). After that comes the name of the language that is contained by the
block. The language must be one of the `short name` lexer strings supported by
Pygments. See the [list of lexers](http://pygments.org/docs/lexers/) for valid
options. Following the language name you may add an additional three backticks
for aesthetic reasons (but this is not required).

If the block contents are indented two spaces or one tab, then that whitespace
will be ignored (this makes the blocks easier to read in plaintext).

The block must end with at least three backticks as the first characters on a
line. You may add more backticks for balance if you like.


## API DOCUMENTATION

The Gollum API allows you to retrieve raw or formatted wiki content from a Git
repository, write new content to the repository, and collect various meta data
about the wiki as a whole.

Initialize the Gollum::Repo object:

    # Require rubygems if necessary
    require 'rubygems'

    # Require the Gollum library
    require 'gollum'

    # Create a new Gollum object by initializing it with the path to the
    # Git repository.
    gollum = Gollum.new("my-gollum-repo.git")
    # => <Gollum::Repo>

Get the latest HTML formatted version of the given canonical page name:

    page = gollum.formatted_page('page-name')
    # => <Gollum::Page>

    page.data
    # => "<h1>My wiki page</h1>"

    page.format
    # => :markdown

    vsn = page.version
    # => <Gollum::Version>

    vsn.id
    # => '3ca43e12377ea1e32ea5c9ce5992ec8bf266e3e5'

Get the latest raw version of the given canonical page name:

    gollum.raw_page('page-name')
    # => <Gollum::Page>

    page.data
    # => "# My wiki page"

    page.format
    # => :markdown

    page.version
    # => <Gollum::Version>

Get a list of versions for a given canonical page name:

    vsns = gollum.page_versions('page-name')
    # => [<Gollum::Version, <Gollum::Version, <Gollum::Version>]

    vsns.first.id
    # => '3ca43e12377ea1e32ea5c9ce5992ec8bf266e3e5'

    vsns.first.date
    # => Sun Mar 28 19:11:21 -0700 2010

Get a specific version of a given canonical page file:

    gollum.formatted_page('page-name', '5ec521178e0eec4dc39741a8978a2ba6616d0f0a')
    gollum.raw_page('page-name', '5ec521178e0eec4dc39741a8978a2ba6616d0f0a')

Get the latest version of a given static file:

    file = gollum.static_file('asset.js')
    # => <Gollum::File>

    file.data
    # => "alert('hello');"

    file.version
    # => <Gollum::Version>

Get a specific version of a given static file:

    gollum.static_file('asset.js', '5ec521178e0eec4dc39741a8978a2ba6616d0f0a')

Write a new version of a given canonical page file (the file will be created
if it does not already exist) and commit the change.

    gollum.write_page('page-name', 'My wiki page contents')

Write a new version of a given canonical page file and specify a commit
message:

    gollum.write_page('page-name', 'My wiki page contents', 'commit message')

To delete a page and commit the change:

    gollum.delete_page('page-name')

Once again, you can optionally specify a commit message:

    gollum.delete_page('page-name', 'commit message')