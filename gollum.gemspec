Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'
  s.required_ruby_version = ">= 1.8.7"

  s.name              = 'gollum'
  s.version           = '2.2.9'
  s.date              = '2012-10-14'
  s.rubyforge_project = 'gollum'

  s.summary     = "A simple, Git-powered wiki."
  s.description = "A simple, Git-powered wiki with a sweet API and local frontend."

  s.authors  = ["Tom Preston-Werner", "Rick Olson"]
  s.email    = 'tom@github.com'
  s.homepage = 'http://github.com/github/gollum'

  s.require_paths = %w[lib]

  s.executables = ["gollum"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency('grit', '~> 2.5.0')
  s.add_dependency('github-markup', ['>= 0.7.4', '< 1.0.0'])
  s.add_dependency('github-markdown', '~> 0.5.1')
  s.add_dependency('pygments.rb', '~> 0.3.1')
  s.add_dependency('escape_utils', '0.2.4')
  s.add_dependency('sinatra', '~> 1.3.3')
  s.add_dependency('mustache', ['>= 0.99.4', '< 1.0.0'])
  s.add_dependency('sanitize', '~> 2.0.3')
  s.add_dependency('nokogiri', '~> 1.5.5')
  s.add_dependency('useragent', '~> 0.4.10')
  s.add_dependency('stringex', '~> 1.4.0')

  s.add_development_dependency('RedCloth', '~> 4.2.9')
  s.add_development_dependency('mocha', '~> 0.12.6')
  s.add_development_dependency('org-ruby', '~> 0.7.1')
  s.add_development_dependency('shoulda', '~> 3.1.1')
  s.add_development_dependency('rack-test', '~> 0.6.2')
  s.add_development_dependency('wikicloth', '~> 0.8.0')
  s.add_development_dependency('rake', '~> 0.9.2.2')

  # = MANIFEST =
  s.files = %w[
    Gemfile
    HISTORY.md
    LICENSE
    README.md
    Rakefile
    bin/gollum
    docs/sanitization.md
    gollum.gemspec
    lib/gollum.rb
    lib/gollum/blob_entry.rb
    lib/gollum/committer.rb
    lib/gollum/file.rb
    lib/gollum/file_view.rb
    lib/gollum/frontend/app.rb
    lib/gollum/frontend/helpers.rb
    lib/gollum/frontend/public/gollum/css/_styles.css
    lib/gollum/frontend/public/gollum/css/dialog.css
    lib/gollum/frontend/public/gollum/css/editor.css
    lib/gollum/frontend/public/gollum/css/gollum.css
    lib/gollum/frontend/public/gollum/css/ie7.css
    lib/gollum/frontend/public/gollum/css/template.css
    lib/gollum/frontend/public/gollum/images/dirty-shade.png
    lib/gollum/frontend/public/gollum/images/fileview/document.png
    lib/gollum/frontend/public/gollum/images/fileview/folder-horizontal.png
    lib/gollum/frontend/public/gollum/images/fileview/toggle-small-expand.png
    lib/gollum/frontend/public/gollum/images/fileview/toggle-small.png
    lib/gollum/frontend/public/gollum/images/icon-sprite.png
    lib/gollum/frontend/public/gollum/images/para.png
    lib/gollum/frontend/public/gollum/images/pin-16.png
    lib/gollum/frontend/public/gollum/images/pin-20.png
    lib/gollum/frontend/public/gollum/images/pin-24.png
    lib/gollum/frontend/public/gollum/images/pin-32.png
    lib/gollum/frontend/public/gollum/javascript/editor/gollum.editor.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/asciidoc.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/creole.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/markdown.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/org.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/pod.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/rdoc.js
    lib/gollum/frontend/public/gollum/javascript/editor/langs/textile.js
    lib/gollum/frontend/public/gollum/javascript/gollum.dialog.js
    lib/gollum/frontend/public/gollum/javascript/gollum.js
    lib/gollum/frontend/public/gollum/javascript/gollum.placeholder.js
    lib/gollum/frontend/public/gollum/javascript/jquery-1.7.2.min.js
    lib/gollum/frontend/public/gollum/javascript/jquery.color.js
    lib/gollum/frontend/public/gollum/javascript/mousetrap.min.js
    lib/gollum/frontend/public/gollum/livepreview/css/custom.css
    lib/gollum/frontend/public/gollum/livepreview/images/cancel_24.png
    lib/gollum/frontend/public/gollum/livepreview/images/lr_24.png
    lib/gollum/frontend/public/gollum/livepreview/images/save_24.png
    lib/gollum/frontend/public/gollum/livepreview/images/savecomment_24.png
    lib/gollum/frontend/public/gollum/livepreview/index.html
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/ace.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/anchor.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/anchor_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/background_tokenizer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/background_tokenizer_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/commands/command_manager.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/commands/command_manager_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/commands/default_commands.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/commands/multi_select_commands.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/config.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/css/codefolding-fold-button-states.png
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/css/editor.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/css/expand-marker.png
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/document.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/document_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session/bracket_match.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session/fold.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session/fold_line.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session/folding.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/edit_session_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/editor.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/editor_change_document_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/editor_highlight_selected_word_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/editor_navigation_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/editor_text_edit_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/ext/static.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/ext/static_highlight.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/ext/static_highlight_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/ext/textarea.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/emacs.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/hash_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/keybinding.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/state_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/textinput.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/commands.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/maps/aliases.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/maps/motions.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/maps/operators.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/maps/util.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/keyboard/vim/registers.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/layer/cursor.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/layer/gutter.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/layer/marker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/layer/text.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/layer/text_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/browser_focus.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/dom.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/es5-shim.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/event.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/event_emitter.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/event_emitter_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/fixoldbrowsers.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/keys.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/lang.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/net.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/oop.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/regexp.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/lib/useragent.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/behaviour.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/behaviour/cstyle.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/behaviour/html.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/behaviour/xml.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/behaviour/xquery.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/c9search.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/c9search_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/c_cpp.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/c_cpp_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/clojure.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/clojure_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/coffee-script.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/helpers.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/lexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/nodes.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/parser.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/parser_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/rewriter.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee/scope.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coffee_worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coldfusion.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coldfusion_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/coldfusion_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/csharp.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/csharp_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css/csslint.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css_worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/css_worker_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/diff.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/diff_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/doc_comment_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/c9search.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/coffee.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/coffee_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/cstyle.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/cstyle_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/diff.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/fold_mode.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/html.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/html_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/mixed.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/pythonic.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/pythonic_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/xml.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/folding/xml_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/golang.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/golang_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/groovy.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/groovy_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/haxe.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/haxe_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/html.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/html_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/html_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/html_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/java.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/java_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript_worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/javascript_worker_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/json.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/json/json_parse.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/json_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/json_worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/json_worker_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/jsx.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/jsx_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/latex.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/latex_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/less.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/less_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/liquid.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/liquid_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/liquid_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/lua.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/lua_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/luapage.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/luapage_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/markdown.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/markdown_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/matching_brace_outdent.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/matching_parens_outdent.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/ocaml.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/ocaml_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/perl.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/perl_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/pgsql.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/pgsql_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/php.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/php_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/powershell.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/powershell_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/python.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/python_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/python_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/ruby.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/ruby_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/ruby_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scad.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scad_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scala.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scala_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scss.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/scss_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/sh.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/sh_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/sql.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/sql_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/svg.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/svg_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/text.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/text_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/text_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/textile.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/textile_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xml.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xml_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xml_highlight_rules_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xml_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xml_util.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/Position.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/Readme.md
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/StringLexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XMLLexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XQDTLexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XQDTParser.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XQueryLexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XQueryParser.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/XQuerySemanticHighlighter.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/antlr3-all.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery/xquery.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/xquery_worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/yaml.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mode/yaml_highlight_rules.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/model/editor.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/default_gutter_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/default_handlers.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/dragdrop.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/fold_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/mouse_event.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/mouse_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/mouse/multi_select_handler.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/multi_select.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/multi_select_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/narcissus/definitions.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/narcissus/lexer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/narcissus/options.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/narcissus/parser.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/placeholder.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/placeholder_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/range.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/range_list.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/range_list_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/range_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/renderloop.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/requirejs/text.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/scrollbar.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/search.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/search_highlight.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/search_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/selection.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/selection_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/split.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/all.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/all_browser.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/assertions.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/asyncjs/assert.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/asyncjs/async.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/asyncjs/index.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/asyncjs/test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/asyncjs/utils.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/benchmark.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/mockdom.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/mockrenderer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/test/tests.html
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/chrome.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/chrome.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/clouds.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/clouds.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/clouds_midnight.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/clouds_midnight.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/cobalt.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/cobalt.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/crimson_editor.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/crimson_editor.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/dawn.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/dawn.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/dreamweaver.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/dreamweaver.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/eclipse.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/eclipse.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/github.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/github.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/idle_fingers.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/idle_fingers.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/kr_theme.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/kr_theme.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/merbivore.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/merbivore.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/merbivore_soft.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/merbivore_soft.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/mono_industrial.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/mono_industrial.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/monokai.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/monokai.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/pastel_on_dark.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/pastel_on_dark.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/solarized_dark.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/solarized_dark.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/solarized_light.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/solarized_light.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/textmate.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/textmate.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_blue.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_blue.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_bright.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_bright.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_eighties.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/tomorrow_night_eighties.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/twilight.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/twilight.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/vibrant_ink.css
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/theme/vibrant_ink.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/token_iterator.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/token_iterator_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/tokenizer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/undomanager.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/unicode.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/virtual_renderer.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/virtual_renderer_test.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/jshint.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/jslint.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/mirror.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/worker.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/worker_client.js
    lib/gollum/frontend/public/gollum/livepreview/js/ace/lib/ace/worker/worker_sourcemint.js
    lib/gollum/frontend/public/gollum/livepreview/js/jquery.ba-throttle-debounce.min.js
    lib/gollum/frontend/public/gollum/livepreview/js/livepreview.js
    lib/gollum/frontend/public/gollum/livepreview/js/md_sundown.js
    lib/gollum/frontend/public/gollum/livepreview/js/requirejs.min.js
    lib/gollum/frontend/public/gollum/livepreview/js/sundown.js
    lib/gollum/frontend/public/gollum/livepreview/licenses/ace/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/bootstraponline_gollum/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/debounce/LICENSE-MIT.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/gollum/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/jquery/MIT-LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/licenses.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/notepages/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/requirejs/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/retina_display_icon_set/by_sa_3.0_unported_legalcode.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/sizzle/LICENSE.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/sundown/sundown.txt
    lib/gollum/frontend/public/gollum/livepreview/licenses/templarian_windowsicons/license.txt
    lib/gollum/frontend/public/gollum/livepreview/readme.md
    lib/gollum/frontend/templates/compare.mustache
    lib/gollum/frontend/templates/create.mustache
    lib/gollum/frontend/templates/edit.mustache
    lib/gollum/frontend/templates/editor.mustache
    lib/gollum/frontend/templates/error.mustache
    lib/gollum/frontend/templates/file_view.mustache
    lib/gollum/frontend/templates/history.mustache
    lib/gollum/frontend/templates/layout.mustache
    lib/gollum/frontend/templates/page.mustache
    lib/gollum/frontend/templates/pages.mustache
    lib/gollum/frontend/templates/search.mustache
    lib/gollum/frontend/templates/searchbar.mustache
    lib/gollum/frontend/uri_encode_component.rb
    lib/gollum/frontend/views/compare.rb
    lib/gollum/frontend/views/create.rb
    lib/gollum/frontend/views/edit.rb
    lib/gollum/frontend/views/editable.rb
    lib/gollum/frontend/views/error.rb
    lib/gollum/frontend/views/file_view.rb
    lib/gollum/frontend/views/has_page.rb
    lib/gollum/frontend/views/history.rb
    lib/gollum/frontend/views/layout.rb
    lib/gollum/frontend/views/page.rb
    lib/gollum/frontend/views/pages.rb
    lib/gollum/frontend/views/search.rb
    lib/gollum/git_access.rb
    lib/gollum/gitcode.rb
    lib/gollum/markup.rb
    lib/gollum/page.rb
    lib/gollum/pagination.rb
    lib/gollum/sanitization.rb
    lib/gollum/tex.rb
    lib/gollum/web_sequence_diagram.rb
    lib/gollum/wiki.rb
    licenses/css_tree_menu_thecssninja/license.txt
    licenses/licenses.txt
    licenses/unity_asset_pool/COPYRIGHT
    templates/formatting.html
    templates/helper_wiki.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end