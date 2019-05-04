Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new('>= 0') if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'
  s.required_ruby_version = '>= 1.9'

  s.name              = 'gollum'
  s.version           = '5.0.1b'
  s.date              = '2018-09-28'
  s.rubyforge_project = 'gollum'
  s.license           = 'MIT'

  s.summary     = 'A simple, Git-powered wiki.'
  s.description = 'A simple, Git-powered wiki with a sweet API and local frontend.'

  s.authors  = ['Tom Preston-Werner', 'Rick Olson']
  s.email    = 'tom@github.com'
  s.homepage = 'http://github.com/gollum/gollum'

  s.require_paths = %w[lib]

  s.executables = ['gollum']

  s.rdoc_options = ['--charset=UTF-8']
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency 'gollum-lib', '~> 5.0.a'
  s.add_dependency 'kramdown', '~> 2.1.0'
  s.add_dependency 'kramdown-parser-gfm', '~> 1.0.0'
  s.add_dependency 'sinatra', '~> 2.0'
  s.add_dependency 'sinatra-contrib', '~> 2.0'
  s.add_dependency 'mustache', ['>= 0.99.5', '< 1.0.0']
  s.add_dependency 'useragent', '~> 0.16.2'
  s.add_dependency 'gemojione', '~> 3.2'
  s.add_dependency 'sprockets', '~> 3.7'
  s.add_dependency 'sass', '~> 3.5'
  s.add_dependency 'uglifier', '~> 3.2'
  s.add_dependency 'sprockets-helpers', '~> 1.2'

  s.add_development_dependency 'rack-test', '~> 0.6.3'
  s.add_development_dependency 'shoulda', '~> 3.6.0'
  s.add_development_dependency 'minitest-reporters', '~> 1.3.6'
  s.add_development_dependency 'twitter_cldr', '~> 3.2.0'
  s.add_development_dependency 'mocha', '~> 1.8.0'
  s.add_development_dependency 'test-unit', '~> 3.3.0'
  s.add_development_dependency 'webrick', '~> 1.4.2'

  # = MANIFEST =
  s.files = %w[
    CONTRIBUTING.md
    Gemfile
    HISTORY.md
    LICENSE
    README.md
    Rakefile
    bin/gollum
    config.rb
    config.ru
    contrib/openrc/conf.d/gollum
    contrib/openrc/init.d/gollum
    contrib/systemd/gollum@.service
    contrib/sysv-debian/init.d/gollum
    gollum.gemspec
    lib/gollum.rb
    lib/gollum/app.rb
    lib/gollum/assets.rb
    lib/gollum/helpers.rb
    lib/gollum/public/gollum/fonts/FontAwesome.otf
    lib/gollum/public/gollum/fonts/fontawesome-webfont.eot
    lib/gollum/public/gollum/fonts/fontawesome-webfont.svg
    lib/gollum/public/gollum/fonts/fontawesome-webfont.ttf
    lib/gollum/public/gollum/fonts/fontawesome-webfont.woff
    lib/gollum/public/gollum/images/dirty-shade.png
    lib/gollum/public/gollum/images/fileview/document.png
    lib/gollum/public/gollum/images/fileview/folder-horizontal.png
    lib/gollum/public/gollum/images/fileview/toggle-small-expand.png
    lib/gollum/public/gollum/images/fileview/toggle-small.png
    lib/gollum/public/gollum/images/fileview/trashcan.png
    lib/gollum/public/gollum/images/icon-sprite.png
    lib/gollum/public/gollum/images/man_24.png
    lib/gollum/public/gollum/images/para.png
    lib/gollum/public/gollum/images/pin-16.png
    lib/gollum/public/gollum/images/pin-20.png
    lib/gollum/public/gollum/images/pin-24.png
    lib/gollum/public/gollum/images/pin-32.png
    lib/gollum/public/gollum/javascript/HOWTO_UPDATE_ACE.md
    lib/gollum/public/gollum/javascript/ace-1.3.1/ace.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-beautify.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-elastic_tabstops_lite.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-emmet.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-error_marker.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-keybinding_menu.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-language_tools.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-linking.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-modelist.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-options.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-searchbox.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-settings_menu.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-spellcheck.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-split.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-static_highlight.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-statusbar.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-textarea.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-themelist.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/ext-whitespace.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/keybinding-emacs.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/keybinding-vim.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-abap.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-abc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-actionscript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ada.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-apache_conf.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-applescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-asciidoc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-assembly_x86.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-autohotkey.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-batchfile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-bro.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-c9search.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-c_cpp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-cirru.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-clojure.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-cobol.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-coffee.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-coldfusion.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-csharp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-csound_document.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-csound_orchestra.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-csound_score.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-csp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-css.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-curly.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-d.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-dart.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-diff.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-django.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-dockerfile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-dot.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-drools.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-edifact.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-eiffel.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ejs.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-elixir.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-elm.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-erlang.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-forth.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-fortran.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ftl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-gcode.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-gherkin.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-gitignore.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-glsl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-gobstones.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-golang.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-graphqlschema.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-groovy.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-haml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-handlebars.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-haskell.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-haskell_cabal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-haxe.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-hjson.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-html.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-html_elixir.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-html_ruby.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ini.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-io.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jack.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jade.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-java.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-javascript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-json.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jsoniq.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jsp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jssm.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-jsx.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-julia.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-kotlin.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-latex.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-less.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-liquid.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-lisp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-livescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-logiql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-lsl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-lua.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-luapage.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-lucene.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-makefile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-markdown.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-mask.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-matlab.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-maze.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-mel.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-mixal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-mushcode.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-mysql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-nix.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-nsis.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-objectivec.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ocaml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-pascal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-perl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-pgsql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-php.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-pig.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-plain_text.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-powershell.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-praat.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-prolog.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-properties.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-protobuf.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-python.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-r.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-razor.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-rdoc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-red.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-redshift.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-rhtml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-rst.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-ruby.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-rust.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sass.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-scad.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-scala.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-scheme.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-scss.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sh.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sjs.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-smarty.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-snippets.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-soy_template.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-space.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sparql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-sqlserver.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-stylus.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-svg.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-swift.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-tcl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-tex.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-text.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-textile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-toml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-tsx.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-turtle.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-twig.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-typescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-vala.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-vbscript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-velocity.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-verilog.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-vhdl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-wollok.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-xml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-xquery.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/mode-yaml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/abap.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/abc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/actionscript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ada.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/apache_conf.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/applescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/asciidoc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/assembly_x86.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/autohotkey.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/batchfile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/bro.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/c9search.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/c_cpp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/cirru.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/clojure.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/cobol.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/coffee.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/coldfusion.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/csharp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/csound_document.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/csound_orchestra.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/csound_score.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/csp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/css.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/curly.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/d.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/dart.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/diff.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/django.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/dockerfile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/dot.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/drools.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/edifact.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/eiffel.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ejs.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/elixir.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/elm.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/erlang.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/forth.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/fortran.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ftl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/gcode.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/gherkin.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/gitignore.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/glsl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/gobstones.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/golang.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/graphqlschema.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/groovy.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/haml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/handlebars.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/haskell.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/haskell_cabal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/haxe.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/hjson.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/html.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/html_elixir.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/html_ruby.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ini.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/io.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jack.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jade.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/java.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/javascript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/json.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jsoniq.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jsp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jssm.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/jsx.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/julia.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/kotlin.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/latex.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/less.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/liquid.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/lisp.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/livescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/logiql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/lsl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/lua.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/luapage.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/lucene.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/makefile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/markdown.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/mask.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/matlab.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/maze.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/mel.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/mixal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/mushcode.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/mysql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/nix.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/nsis.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/objectivec.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ocaml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/pascal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/perl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/pgsql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/php.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/pig.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/plain_text.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/powershell.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/praat.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/prolog.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/properties.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/protobuf.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/python.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/r.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/razor.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/rdoc.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/red.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/redshift.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/rhtml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/rst.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/ruby.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/rust.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sass.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/scad.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/scala.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/scheme.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/scss.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sh.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sjs.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/smarty.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/snippets.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/soy_template.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/space.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sparql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sql.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/sqlserver.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/stylus.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/svg.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/swift.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/tcl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/tex.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/text.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/textile.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/toml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/tsx.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/turtle.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/twig.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/typescript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/vala.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/vbscript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/velocity.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/verilog.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/vhdl.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/wollok.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/xml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/xquery.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/snippets/yaml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-ambiance.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-chaos.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-chrome.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-clouds.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-clouds_midnight.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-cobalt.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-crimson_editor.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-dawn.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-dracula.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-dreamweaver.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-eclipse.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-github.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-gob.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-gruvbox.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-idle_fingers.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-iplastic.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-katzenmilch.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-kr_theme.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-kuroir.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-merbivore.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-merbivore_soft.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-mono_industrial.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-monokai.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-pastel_on_dark.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-solarized_dark.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-solarized_light.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-sqlserver.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-terminal.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-textmate.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-tomorrow.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-tomorrow_night.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-tomorrow_night_blue.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-tomorrow_night_bright.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-tomorrow_night_eighties.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-twilight.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-vibrant_ink.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/theme-xcode.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-coffee.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-css.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-html.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-javascript.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-json.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-lua.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-php.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-xml.js
    lib/gollum/public/gollum/javascript/ace-1.3.1/worker-xquery.js
    lib/gollum/public/gollum/javascript/app.js
    lib/gollum/public/gollum/javascript/editor/gollum.editor.js
    lib/gollum/public/gollum/javascript/editor/langs/asciidoc.js
    lib/gollum/public/gollum/javascript/editor/langs/creole.js
    lib/gollum/public/gollum/javascript/editor/langs/markdown.js
    lib/gollum/public/gollum/javascript/editor/langs/org.js
    lib/gollum/public/gollum/javascript/editor/langs/pod.js
    lib/gollum/public/gollum/javascript/editor/langs/rdoc.js
    lib/gollum/public/gollum/javascript/editor/langs/textile.js
    lib/gollum/public/gollum/javascript/gollum.dialog.js
    lib/gollum/public/gollum/javascript/gollum.js
    lib/gollum/public/gollum/javascript/gollum.placeholder.js
    lib/gollum/public/gollum/javascript/identicon_canvas.js
    lib/gollum/public/gollum/javascript/jquery-1.7.2.min.js
    lib/gollum/public/gollum/javascript/jquery.resize.js
    lib/gollum/public/gollum/javascript/mousetrap.min.js
    lib/gollum/public/gollum/stylesheets/_base.scss
    lib/gollum/public/gollum/stylesheets/_breakpoint.scss
    lib/gollum/public/gollum/stylesheets/_component.scss
    lib/gollum/public/gollum/stylesheets/_features.scss
    lib/gollum/public/gollum/stylesheets/_layout.scss
    lib/gollum/public/gollum/stylesheets/app.scss
    lib/gollum/public/gollum/stylesheets/dialog.scss
    lib/gollum/public/gollum/stylesheets/editor.scss
    lib/gollum/public/gollum/stylesheets/fileview.scss
    lib/gollum/public/gollum/stylesheets/gollum.scss
    lib/gollum/public/gollum/stylesheets/ie7.scss
    lib/gollum/public/gollum/stylesheets/print.scss
    lib/gollum/public/gollum/stylesheets/template.scss
    lib/gollum/templates/compare.mustache
    lib/gollum/templates/create.mustache
    lib/gollum/templates/edit.mustache
    lib/gollum/templates/editor.mustache
    lib/gollum/templates/error.mustache
    lib/gollum/templates/history.mustache
    lib/gollum/templates/history_authors/gravatar.mustache
    lib/gollum/templates/history_authors/identicon.mustache
    lib/gollum/templates/history_authors/none.mustache
    lib/gollum/templates/latest_changes.mustache
    lib/gollum/templates/layout.mustache
    lib/gollum/templates/page.mustache
    lib/gollum/templates/pages.mustache
    lib/gollum/templates/search.mustache
    lib/gollum/templates/searchbar.mustache
    lib/gollum/uri_encode_component.rb
    lib/gollum/views/compare.rb
    lib/gollum/views/create.rb
    lib/gollum/views/edit.rb
    lib/gollum/views/editable.rb
    lib/gollum/views/error.rb
    lib/gollum/views/has_page.rb
    lib/gollum/views/helpers.rb
    lib/gollum/views/history.rb
    lib/gollum/views/latest_changes.rb
    lib/gollum/views/layout.rb
    lib/gollum/views/page.rb
    lib/gollum/views/pages.rb
    lib/gollum/views/search.rb
    licenses/css_tree_menu_thecssninja/license.txt
    licenses/licenses.txt
    licenses/unity_asset_pool/COPYRIGHT
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
