Gem::Specification.new do |s|
  s.specification_version = 2 if s.respond_to? :specification_version=
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.rubygems_version = '1.3.5'

  s.name              = 'gollum'
  s.version           = '0.0.1'
  s.date              = '2010-07-12'
  s.rubyforge_project = 'gollum'

  s.summary     = "Short description used in Gem listings."
  s.description = "Long description. Maybe copied from the README."

  s.authors  = ["Tom Preston-Werner"]
  s.email    = 'tom@github.com'
  s.homepage = 'http://github.com/github/gollum'

  s.require_paths = %w[lib]

  s.executables = ["gollum"]
  s.default_executable = 'gollum'

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency('grit', "~> 2.0.0")
  s.add_dependency('github-markup', [">= 0.4.0", "< 1.0.0"])
  s.add_dependency('albino', "~> 1.0.0")
  s.add_dependency('sinatra', "~> 1.0.0")
  s.add_dependency('mustache', [">= 0.11.2", "< 1.0.0"])
  s.add_dependency('sanitize', "~> 1.0.0")
  s.add_dependency('nokogiri', "~> 1.0.0")

  s.add_development_dependency('shoulda')
  s.add_development_dependency('mocha')
  s.add_development_dependency('org-ruby')

  # = MANIFEST =
  s.files = %w[
    LICENSE
    README.md
    Rakefile
    gollum.gemspec
    lib/gollum.rb
    lib/gollum/albino.rb
    lib/gollum/file.rb
    lib/gollum/frontend/app.rb
    lib/gollum/frontend/public/css/global.css
    lib/gollum/frontend/public/css/gollum.css
    lib/gollum/frontend/public/css/screen.css
    lib/gollum/frontend/public/css/syntax.css
    lib/gollum/frontend/public/javascript/jquery-1.4.2.min.js
    lib/gollum/frontend/templates/create.mustache
    lib/gollum/frontend/templates/edit.mustache
    lib/gollum/frontend/templates/layout.mustache
    lib/gollum/frontend/templates/page.mustache
    lib/gollum/frontend/views/create.rb
    lib/gollum/frontend/views/edit.rb
    lib/gollum/frontend/views/layout.rb
    lib/gollum/frontend/views/page.rb
    lib/gollum/markup.rb
    lib/gollum/page.rb
    lib/gollum/pagination.rb
    lib/gollum/wiki.rb
    templates/formatting.html
    test/examples/lotr.git/HEAD
    test/examples/lotr.git/config
    test/examples/lotr.git/description
    test/examples/lotr.git/hooks/applypatch-msg.sample
    test/examples/lotr.git/hooks/commit-msg.sample
    test/examples/lotr.git/hooks/post-commit.sample
    test/examples/lotr.git/hooks/post-receive.sample
    test/examples/lotr.git/hooks/post-update.sample
    test/examples/lotr.git/hooks/pre-applypatch.sample
    test/examples/lotr.git/hooks/pre-commit.sample
    test/examples/lotr.git/hooks/pre-rebase.sample
    test/examples/lotr.git/hooks/prepare-commit-msg.sample
    test/examples/lotr.git/hooks/update.sample
    test/examples/lotr.git/info/exclude
    test/examples/lotr.git/objects/01/676dc56d35c1999c6fe9043fe8b78d52a0e797
    test/examples/lotr.git/objects/07/9a5887755dc6fbacfdb672abc168b0cce698fa
    test/examples/lotr.git/objects/0a/de1e2916346d4c1f2fb63b863fd3c16808fe44
    test/examples/lotr.git/objects/0e/ea197b933bd98373114d59c7e49728741af3f9
    test/examples/lotr.git/objects/0e/eab62a59300666b4093cf2cfa196c1fedd0e71
    test/examples/lotr.git/objects/11/5bbf9fe8004aa6a06274b44ab93a84a06e3204
    test/examples/lotr.git/objects/13/304aef8994111be14b5168e5d09bc090e9e5c7
    test/examples/lotr.git/objects/14/78ebf7ad4dc6a06c76cdb4aca0eba7f78796aa
    test/examples/lotr.git/objects/17/ff02e9eca7b922b839000e20ad2e853e3bbd45
    test/examples/lotr.git/objects/1d/a113feb1d30a8b207b7d54121a41f9563a4983
    test/examples/lotr.git/objects/1e/716a3178a76fe39ee7b88f0cf2dc4a447566f6
    test/examples/lotr.git/objects/28/bb2f40d2e4c82a4ae62ef619a80a4b555e23ee
    test/examples/lotr.git/objects/2c/b9156ad383914561a8502fc70f5a1d887e48ad
    test/examples/lotr.git/objects/36/38047bb1f46401b9e2171faf2d11d0ac94ad7a
    test/examples/lotr.git/objects/37/fcc52509fb09142cafccaada0252f3de81873c
    test/examples/lotr.git/objects/4c/770a352f1e86071b680f879a89874bf59008fa
    test/examples/lotr.git/objects/4f/de706c7c8d3b30b6caec8c82ff4c01261350f2
    test/examples/lotr.git/objects/59/e540724606c84c5aca19cda36cbed22ac495e9
    test/examples/lotr.git/objects/5b/c1aaec6149e854078f1d0f8b71933bbc6c2e43
    test/examples/lotr.git/objects/71/4323c104239440a5c66ab12a67ed07a83c404f
    test/examples/lotr.git/objects/79/8f6564abb42d7ed34621d53595cbbe84638949
    test/examples/lotr.git/objects/7c/7251d713278633fbe506e1b74aba6c91ddd562
    test/examples/lotr.git/objects/93/633112529b0d0bdf25c2206682e59e9f5572e5
    test/examples/lotr.git/objects/a3/46f056d6d8e89f034489e403b3924fbc95f201
    test/examples/lotr.git/objects/af/e2034d400ba21e13361f38f74900c51dbc7fde
    test/examples/lotr.git/objects/b0/d108328459e44fff4a76cd19b10ddc34adce4b
    test/examples/lotr.git/objects/b3/14b19c56ee272a7c9dc379996d9a32f5c463d7
    test/examples/lotr.git/objects/bc/d5c99495011915971b2c9e38da8e5aacfe875d
    test/examples/lotr.git/objects/bf/b7c7a5cde53272a1d202e08bdef4058de85133
    test/examples/lotr.git/objects/c3/b43e9f08966b088e7a0192e436b7a884542e05
    test/examples/lotr.git/objects/d1/a6fb8d766ce6eab2ec0a8f72fdd3171253138d
    test/examples/lotr.git/objects/d4/b4cb628364deedb0b32c2e1dbd21967768432f
    test/examples/lotr.git/objects/d9/e379fdea55b6ff3b71c110b3d2d7b55bbfd5ee
    test/examples/lotr.git/objects/df/26e61e707116f81ebc6b935ec6d1676b7e96c4
    test/examples/lotr.git/objects/e3/415337d9ae2c0b4b00054a93727f4a7d3c3ca5
    test/examples/lotr.git/objects/ec/da3205bee14520aab5a7bb307392064b938e83
    test/examples/lotr.git/objects/ec/fec5774b0a4dd632f3f092e2fa1f73c0aab247
    test/examples/lotr.git/objects/f0/1428b3138994aab19d5f880b6f37336ddf1f24
    test/examples/lotr.git/objects/f2/5eccd98e9b667f9e22946f3e2f945378b8a72d
    test/examples/lotr.git/objects/f4/46205ac9df5b6a40c00785f06827f4a4dbd727
    test/examples/lotr.git/objects/fa/e7ef5344202bba4129abdc13060d9297d99465
    test/examples/lotr.git/objects/fb/abba862dfa7ac35b39042dd4ad780c9f67b8cb
    test/examples/lotr.git/packed-refs
    test/examples/lotr.git/refs/heads/master
    test/helper.rb
    test/test_file.rb
    test/test_markup.rb
    test/test_page.rb
    test/test_wiki.rb
  ]
  # = MANIFEST =

  s.test_files = s.files.select { |path| path =~ /^test\/test_.*\.rb/ }
end