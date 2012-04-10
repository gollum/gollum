Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'gollum'
  s.version           = '1.3.1'
  s.date              = '2011-07-21'
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

  s.add_dependency('grit', "~> 2.4.1")
  s.add_dependency('github-markup', [">= 0.7.0", "< 1.0.0"])
  s.add_dependency('pygments.rb', "~> 0.2.0")
  s.add_dependency('posix-spawn', "~> 0.3.0")
  s.add_dependency('sinatra', "~> 1.0")
  s.add_dependency('mustache', [">= 0.11.2", "< 1.0.0"])
  s.add_dependency('sanitize', "~> 2.0.0")
  s.add_dependency('nokogiri', "~> 1.4")
  s.add_dependency('redcarpet')

  s.add_development_dependency('RedCloth')
  s.add_development_dependency('mocha')
  s.add_development_dependency('org-ruby')
  s.add_development_dependency('shoulda')
  s.add_development_dependency('rack-test')
  s.add_development_dependency('wikicloth', '~> 0.6.3')
  s.add_development_dependency('rake', '~> 0.9.2')

  # = MANIFEST =
  s.files = %w[
    Gemfile
    HISTORY.md
    Home.md
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
    lib/gollum/frontend/app.rb
    lib/gollum/frontend/public/css/dialog.css
    lib/gollum/frontend/public/css/editor.css
    lib/gollum/frontend/public/css/gollum.css
    lib/gollum/frontend/public/css/ie7.css
    lib/gollum/frontend/public/css/template.css
    lib/gollum/frontend/public/images/icon-sprite.png
    lib/gollum/frontend/public/javascript/editor/gollum.editor.js
    lib/gollum/frontend/public/javascript/editor/langs/asciidoc.js
    lib/gollum/frontend/public/javascript/editor/langs/creole.js
    lib/gollum/frontend/public/javascript/editor/langs/markdown.js
    lib/gollum/frontend/public/javascript/editor/langs/org.js
    lib/gollum/frontend/public/javascript/editor/langs/pod.js
    lib/gollum/frontend/public/javascript/editor/langs/rdoc.js
    lib/gollum/frontend/public/javascript/editor/langs/textile.js
    lib/gollum/frontend/public/javascript/gollum.dialog.js
    lib/gollum/frontend/public/javascript/gollum.js
    lib/gollum/frontend/public/javascript/gollum.placeholder.js
    lib/gollum/frontend/public/javascript/jquery.color.js
    lib/gollum/frontend/public/javascript/jquery.js
    lib/gollum/frontend/templates/compare.mustache
    lib/gollum/frontend/templates/create.mustache
    lib/gollum/frontend/templates/edit.mustache
    lib/gollum/frontend/templates/editor.mustache
    lib/gollum/frontend/templates/error.mustache
    lib/gollum/frontend/templates/history.mustache
    lib/gollum/frontend/templates/layout.mustache
    lib/gollum/frontend/templates/page.mustache
    lib/gollum/frontend/templates/pages.mustache
    lib/gollum/frontend/templates/search.mustache
    lib/gollum/frontend/templates/searchbar.mustache
    lib/gollum/frontend/views/compare.rb
    lib/gollum/frontend/views/create.rb
    lib/gollum/frontend/views/edit.rb
    lib/gollum/frontend/views/editable.rb
    lib/gollum/frontend/views/error.rb
    lib/gollum/frontend/views/history.rb
    lib/gollum/frontend/views/layout.rb
    lib/gollum/frontend/views/page.rb
    lib/gollum/frontend/views/pages.rb
    lib/gollum/frontend/views/search.rb
    lib/gollum/git_access.rb
    lib/gollum/markup.rb
    lib/gollum/page.rb
    lib/gollum/pagination.rb
    lib/gollum/sanitization.rb
    lib/gollum/wiki.rb
    templates/formatting.html
    test/examples/lotr.git/COMMIT_EDITMSG
    test/examples/lotr.git/HEAD
    test/examples/lotr.git/config
    test/examples/lotr.git/description
    test/examples/lotr.git/index
    test/examples/lotr.git/info/exclude
    test/examples/lotr.git/logs/HEAD
    test/examples/lotr.git/logs/refs/heads/master
    test/examples/lotr.git/objects/06/131480411710c92a82fe2d1e76932c70feb2e5
    test/examples/lotr.git/objects/0a/de1e2916346d4c1f2fb63b863fd3c16808fe44
    test/examples/lotr.git/objects/0e/d8cbe0a25235bd867e65193c7d837c66b328ef
    test/examples/lotr.git/objects/24/49c2681badfd3c189e8ed658dacffe8ba48fe5
    test/examples/lotr.git/objects/2c/b9156ad383914561a8502fc70f5a1d887e48ad
    test/examples/lotr.git/objects/5d/cac289a8603188d2c5caf481dcba2985126aaa
    test/examples/lotr.git/objects/60/f12f4254f58801b9ee7db7bca5fa8aeefaa56b
    test/examples/lotr.git/objects/71/4323c104239440a5c66ab12a67ed07a83c404f
    test/examples/lotr.git/objects/84/0ec5b1ba1320e8ec443f28f99566f615d5af10
    test/examples/lotr.git/objects/93/6b83ee0dd8837adb82511e40d5e4ebe59bb675
    test/examples/lotr.git/objects/94/523d7ae48aeba575099dd12926420d8fd0425d
    test/examples/lotr.git/objects/96/97dc65e095658bbd1b8e8678e08881e86d32f1
    test/examples/lotr.git/objects/a3/1ca2a7c352c92531a8b99815d15843b259e814
    test/examples/lotr.git/objects/a8/ad3c09dd842a3517085bfadd37718856dee813
    test/examples/lotr.git/objects/aa/b61fe89d56f8614c0a8151da34f939dcedfa68
    test/examples/lotr.git/objects/c3/b43e9f08966b088e7a0192e436b7a884542e05
    test/examples/lotr.git/objects/dc/596d6b2dd89ab05c66f4abd7d5eb706bc17f19
    test/examples/lotr.git/objects/ec/da3205bee14520aab5a7bb307392064b938e83
    test/examples/lotr.git/objects/fa/e7ef5344202bba4129abdc13060d9297d99465
    test/examples/lotr.git/objects/info/packs
    test/examples/lotr.git/objects/pack/pack-dcbeaf3f6ff6c5eb08ea2b0a2d83626e8763546b.idx
    test/examples/lotr.git/objects/pack/pack-dcbeaf3f6ff6c5eb08ea2b0a2d83626e8763546b.pack
    test/examples/lotr.git/packed-refs
    test/examples/lotr.git/refs/heads/master
    test/examples/lotr.git/refs/remotes/origin/HEAD
    test/examples/page_file_dir.git/COMMIT_EDITMSG
    test/examples/page_file_dir.git/HEAD
    test/examples/page_file_dir.git/config
    test/examples/page_file_dir.git/description
    test/examples/page_file_dir.git/index
    test/examples/page_file_dir.git/info/exclude
    test/examples/page_file_dir.git/logs/HEAD
    test/examples/page_file_dir.git/logs/refs/heads/master
    test/examples/page_file_dir.git/objects/0c/7d27db1f575263efdcab3dc650f4502a2dbcbf
    test/examples/page_file_dir.git/objects/22/b404803c966dd92865614d86ff22ca12e50c1e
    test/examples/page_file_dir.git/objects/25/7cc5642cb1a054f08cc83f2d943e56fd3ebe99
    test/examples/page_file_dir.git/objects/57/16ca5987cbf97d6bb54920bea6adde242d87e6
    test/examples/page_file_dir.git/objects/5b/43e14e0a15fb6f08feab1773d1c0991e9f71e2
    test/examples/page_file_dir.git/refs/heads/master
    test/examples/revert.git/COMMIT_EDITMSG
    test/examples/revert.git/HEAD
    test/examples/revert.git/config
    test/examples/revert.git/description
    test/examples/revert.git/index
    test/examples/revert.git/info/exclude
    test/examples/revert.git/logs/HEAD
    test/examples/revert.git/logs/refs/heads/master
    test/examples/revert.git/objects/20/2ced67cea93c7b6bd2928aa1daef8d1d55a20d
    test/examples/revert.git/objects/41/76394bfa11222363c66ce7e84b5f154095b6d9
    test/examples/revert.git/objects/6a/69f92020f5df77af6e8813ff1232493383b708
    test/examples/revert.git/objects/b4/785957bc986dc39c629de9fac9df46972c00fc
    test/examples/revert.git/objects/f4/03b791119f8232b7cb0ba455c624ac6435f433
    test/examples/revert.git/objects/info/packs
    test/examples/revert.git/objects/pack/pack-a561f8437234f74d0bacb9e0eebe52d207f5770d.idx
    test/examples/revert.git/objects/pack/pack-a561f8437234f74d0bacb9e0eebe52d207f5770d.pack
    test/examples/revert.git/packed-refs
    test/examples/revert.git/refs/heads/master
    test/examples/revert.git/refs/remotes/origin/HEAD
    test/examples/yubiwa.git/HEAD
    test/examples/yubiwa.git/config
    test/examples/yubiwa.git/description
    test/examples/yubiwa.git/info/exclude
    test/examples/yubiwa.git/objects/10/fa2ddc4e3b4009d8a453aace10bd6148c1ad00
    test/examples/yubiwa.git/objects/52/4b82874327ea7cbf730389964ba7cb3de966de
    test/examples/yubiwa.git/objects/58/3fc201cb457fb3f1480f3e1e5999b119633835
    test/examples/yubiwa.git/objects/87/bc1dd46ab3d3874d4e898d45dd512cc20a7cc8
    test/examples/yubiwa.git/objects/89/64ed1b4e21aa90e831763bbce9034bfda81b70
    test/examples/yubiwa.git/objects/9f/f6dd0660da5fba2d3374adb2b84fa653bb538b
    test/examples/yubiwa.git/objects/ac/e97abf2b177815a1972d7db22f229f58c83309
    test/examples/yubiwa.git/objects/b1/f443863a4816628807fbf86141ebef055dda34
    test/examples/yubiwa.git/refs/heads/master
    test/examples/empty.git/info/exclude
    test/examples/empty.git/hooks/pre-commit.sample
    test/examples/empty.git/hooks/pre-rebase.sample
    test/examples/empty.git/hooks/post-update.sample
    test/examples/empty.git/hooks/applypatch-msg.sample
    test/examples/empty.git/hooks/prepare-commit-msg.sample
    test/examples/empty.git/hooks/commit-msg.sample
    test/examples/empty.git/hooks/post-receive.sample
    test/examples/empty.git/hooks/post-commit.sample
    test/examples/empty.git/hooks/update.sample
    test/examples/empty.git/hooks/pre-applypatch.sample
    test/examples/empty.git/config
    test/examples/empty.git/HEAD
    test/examples/empty.git/description
    test/helper.rb
    test/test_app.rb
    test/test_committer.rb
    test/test_file.rb
    test/test_git_access.rb
    test/test_markup.rb
    test/test_page.rb
    test/test_page_revert.rb
    test/test_wiki.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end
