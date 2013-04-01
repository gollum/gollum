JGit
=====

###A JRuby wrapper around the [JGit library](https://github.com/eclipse/jgit) for manipulating Git repositories, the Ruby way.

Authors
-------

RJGit is being developed by Team Repotag:

- [Maarten Engelen](https://github.com/maarten)
- [Bart Kamphorst](https://github.com/bartkamphorst)
- [Dawa Ometto](https://github.com/dometto)
- [Arlette van Wissen](https://github.com/arlettevanwissen)
- [Steven Woudenberg](https://github.com/stevenwoudenberg)

With special thanks to:
- Patrick Pepels

Installation
------------
Install the rjgit gem with the command:

$ gem install rjgit

#### Dependencies for using RJGit:
- JRuby >= 1.7.0
- mime-types >= 1.15

#### Further dependencies for developing RJGIT:
- rake >= 0.9.2.2
- rspec >= 2.0
- simplecov

Usage
-----
RJGit wraps most (if not all) of JGit's core functionality; see below for some examples of what you can do with it. Make sure you have [JRuby](http://jruby.org/) installed.

### Require the gem and include the RJGit module

```ruby
require "rjgit"
include RJGit
```

### Initializing an existing repository on the filesystem

```ruby
repo = Repo.new("repo.git")
```

### Creating a new repository

```ruby
repo = Repo.new("repo.git", :create => true)
repo = Repo.new("repo.git", :create => true, :bare => true) # Create a 'bare' git repo, which stores all git-data under the '.git' directory.
```

### Getting a list of commits
```ruby
repo.commits('master')
repo.commits('959329025f67539fb82e76b02782322fad032821')
# Similarly for getting tags, branches, trees (directories), and blobs (files).
```

### Getting tags
```ruby
tag = repo.tags['example_tag']
tag.id # tag's object id
tag.author.name # Etcetera
```

### Getting a repository's contents
```ruby
repo.blob("example/file.txt") # Retrieve a file by filepath
repo.blob("example/file.txt").data # Cat the file
repo.tree("example") # Retrieve a tree by filepath
repo.tree("example").data # List the tree's contents (blobs and trees)
Porcelain::ls_tree(repo, repo.tree("example"), :print => true, :recursive => true, :branch => 'mybranch') # Outputs a file list to $stdout. Passing nil as the second argument lists the entire repository. Branch defaults to HEAD.
```

### Manipulating repositories
```ruby
repo.create_branch('new_branch') # Similarly for deleting, renaming
repo.checkout('new_branch')
repo.add('new_file.txt') # Similarly for removing
repo.commit('My message')
```

### And more...
```ruby
pack = RJGitReceivePack.new(repo) # Implement the smart-http protocol with RJGitReceivePack and RJGitUploadPack
pack.receive(client_msg) # Respond to a client's GET request
repo.config['remote origin']['url'] # Retrieve config values
Porcelain::diff(repo, options)
Porcelain::blame(repo, options)
```

Issues
---------------
Please let us know by creating a [github issue](https://github.com/repotag/rjgit/issues).

Contributing
---------------


1. Fork the project
1. Create a new branch
1. Modify the sources
1. Add specs with full coverage for your new code
1. Make sure the whole test suite passes by running rake
1. Push the branch up to GitHub
1. Send us a pull request


License
-------
Copyright (c) 2011 - 2013, Team Repotag

(Modified BSD License)

All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright
  notice, this list of conditions and the following disclaimer.
* Redistributions in binary form must reproduce the above copyright
  notice, this list of conditions and the following disclaimer in the
  documentation and/or other materials provided with the distribution.
* Neither the name of the organization nor the
  names of its contributors may be used to endorse or promote products
  derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL <COPYRIGHT HOLDER> BE LIABLE FOR ANY
DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
