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
choose. Special footers can be created in `footer files`. Other content
(images, PDFs, etc) may also be present and organized in the same way.


## PAGE FILES

Page files may be written in any format supported by
[GitHub-Markup](http://github.com/defunkt/github-markup). The current list of
formats and allowed extensions is:

  * Markdown: .markdown, .mdown, .mkdn, .mkd, .md
  * Textile: .textile
  * RDoc: .rdoc
  * Org Mode: .org
  * ReStructured Text: .rest.txt, .rst.txt, .rest, .rst
  * ASCIIDoc: .asciidoc
  * POD: .pod
  * Roff: .1, .2, .3, ...

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


## FOOTER FILES

Footer files allow you to add a simple footer to your wiki. Footer files must
be named `_Footer.ext` where the extension is one of the supported formats.
Footers affect all pages in their directory and any subdirectories that do not
have a footer file of their own.


## HTML SANITIZATION

For security and compatibility reasons Gollum wikis may not contain custom CSS
or JavaScript. These tags will be stripped from the converted HTML.


## PAGE LINKS

To link to another Gollum wiki page, use the Gollum Page Link Tag.

    [[Frodo]]

The above tag will create a link to the corresponding page file named
`Frodo.ext` where `ext` may be any of the allowed extension types. The
conversion is as follows:

  1. Strip any non-printables ()
  2. Replace any spaces () with dashes
  3. Replace any slashes () with dashes

If you'd like the link text to be something that doesn't map directly to the
page name, you can specify the actual page name after a pipe:

    [[Frodo|Frodo Baggins]]

The above tag will link to `Frodo-Baggins.ext` using "Frodo" as the link text.

The page file may exist anywhere in the directory structure of the repository.
Gollum does a breadth first search and uses the first match that it finds.

Here are a few more examples:

    [[J. R. R. Tolkien]]    -> J.-R.-R.-Tolkien.ext
    [[Movies / The Hobbit]] -> Movies---The-Hobbit.ext
    [[モルドール]]               -> モルドール.ext


## ABSOLUTE VS. RELATIVE PATHS

For Gollum tags that operate on static files (images, PDFs, etc), the paths
may be referenced as either relative or absolute. Relative paths point to a
static file relative to the page file within the directory structure of the
Gollum repo (even though after conversion, all page files appear to be top
level). These paths are NOT prefixed with a slash. For example:

    gollum.pdf
    docs/diagram.png

Absolute paths point to a static file relative to the Gollum repo's
root, regardless of where the page file is stored within the directory
structure. These paths ARE prefixed with a slash. For example:

    /pdfs/gollum.pdf
    /docs/diagram.png

All of the examples in this README use relative paths, but you may use
whatever works best in your situation.


## FILE LINKS

To link to static files that are contained in the Gollum repository you should
use the Gollum File Link Tag.

    [[Gollum|gollum.pdf]]


## IMAGES

To display images that are contained in the Gollum repository you should use
the Gollum Image Tag. This will display the actual image on the page.

    [[gollum.png]]

In addition to the simple format, there are a variety of options that you
can specify between pipe delimieters.

To specify alt text, use the `alt=` option. Default is no alt text.

    [[gollum.png|alt=Gollum and his precious wiki]]

To place the image in a frame, use the `frame` option. When combined with the
`alt=` option, the alt text will be used as a caption as well. Default is no
frame.

    [[gollum.png|frame|alt=Gollum and his precious wiki]]

To specify the alignment of the image on the page, use the `align=` option.
Possible values are `left`, `center`, and `right`. Default is `center`.

    [[gollum.png|align=center]]

To float an image so that text flows around it, use the `float` option.
Default is not floating.

    [[gollum.png|float]]

To specify a max-width, use the `width=` option. Units must be specified in
either `px` or `em`. Default is `250px`.

    [[gollum.png|width=400px]]

To specify a max-height, use the `height=` option. Units must be specified in
either `px` or `em`. Default is `250px`.

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