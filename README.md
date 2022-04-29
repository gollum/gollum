RJGit
=====

### A JRuby wrapper around the [JGit library](https://github.com/eclipse/jgit) for manipulating Git repositories, the Ruby way.

[![Ruby Build](https://github.com/repotag/rjgit/actions/workflows/test.yaml/badge.svg)](https://github.com/repotag/rjgit/actions/workflows/test.yaml)
[![Coverage Status](https://coveralls.io/repos/repotag/rjgit/badge.png?branch=master)](https://coveralls.io/r/repotag/rjgit)
[![Gem Version](https://badge.fury.io/rb/rjgit.png)](http://badge.fury.io/rb/rjgit)
[![Cutting Edge Dependency Status](https://dometto-cuttingedge.herokuapp.com/github/repotag/rjgit/svg 'Cutting Edge Dependency Status')](https://dometto-cuttingedge.herokuapp.com/github/repotag/rjgit/info)

Summary
-------

RJGit provides a fully featured library for accessing and manipulating git repositories by wrapping the Java [JGit library](https://github.com/eclipse/jgit). It thus provides similiar functionality as e.g. [rugged](https://github.com/libgit2/rugged) on JRuby.

Installation
------------
Install the rjgit gem with the command:

```sh
$ gem install rjgit
```

#### Dependencies for using RJGit:
- JRuby >= 1.7.0
- mime-types >= 1.15

#### Further dependencies for developing RJGIT:
- rake >= 0.9.2.2
- rspec >= 2.0
- simplecov

#### Version scheme

RJGit's version number is the version of jgit used, plus our own patch level counter. For instance, RJGit 4.0.1.0 uses jgit 4.0.1, patch level 0.

Usage
-----
RJGit wraps most (if not all) of JGit's core functionality; it has classes for all important Git objects, i.e., Repo, Blob, Tree, Commit, and Tag. It allows parsing and manipulation of these objects in an intuitive manner, either simulating ordinary git usage (with a working directory on disk) or on a lower level, through creating new git objects manually (also works with 'bare' repositories, without a working directory).

See below for some examples of what you can do with RJGit. Make sure you have [JRuby](http://jruby.org/) installed.

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
repo = Repo.new("repo.git", :create => true, :is_bare => true) # Create a 'bare' git repo.
repo.bare? # Is this a bare repository?
```

### Getting commits
```ruby
repo.commits('master')
repo.commits('959329025f67539fb82e76b02782322fad032821')
repo.head
commit = repo.commits('master').first # a Commit object; try commit.actor, commit.id, etc.
# Similarly for getting tags, branches, trees (directories), and blobs (files).
```

### Finding a single object by SHA
```ruby
repo.find('959329025f67539fb82e76b02782322fad032821')
repo.find('959329025f67539fb82e76b02782322fad032821', :commit) # Find a specific :commit, :blob, :tree, or :tag
```

### Logs

```ruby
repo.git.log # Returns an Array of Commits constituting the log for the default branch
repo.git.log("follow-rename.txt", "HEAD", follow: true, list_renames: true) # Log for a specific path, tracking the pathname over renames. Returns an Array of TrackingCommits, which store the tracked filename: [#<RJGit::TrackingCommit:0x773014d3 @tracked_pathname="follow-rename.txt" ...>]
```

### Getting diffs
```ruby
sha1 = repo.head.id
sha2 = repo.commits.last.id
options = {:old_rev => sha2, :new_rev => sha1, :file_path => "some/path.txt", :patch => true}
Porcelain.diff(repo, options)
```

### Getting tags
```ruby
tag = repo.tags['example_tag']
tag.id # tag's object id
tag.author.name # Etcetera
some_object = Porcelain.object_for_tag(repo, tag) # Returns the tagged object; e.g. a Commit
```

### Blobs and Trees
```ruby
blob = repo.blob("example/file.txt") # Retrieve a file by filepath...
blob = repo.find("959329025f67539fb82e76b02782322fad032822", :blob) # ...or by SHA
blob.data # Cat the file; also blob.id, blob.mode, etc.
tree = repo.tree("example") # Retrieve a tree by filepath...
tree = repo.find("959329025f67539fb82e76b02782322fad032000", :tree) #...or by SHA
tree.data # List the tree's contents (blobs and trees). Also tree.id, tree.mode, etc.
tree.each {|entry| puts entry.inspect} # Loop over the Tree's children (Blobs and Trees)
tree.trees # An array of the Tree's child Trees
tree.blobs # An array of the Tree's child Blobs
Porcelain::ls_tree(repo, repo.tree("example"), :print => true, :recursive => true, :ref => 'mybranch') # Outputs the Tree's contents to $stdout. Faster for recursive listing than Tree#each. Passing nil as the second argument lists the entire repository. ref defaults to HEAD.
```

### Creating blobs and trees from scratch
```ruby
blob = Blob.new_from_string(repo, "Contents of the new blob.") # Inserts the blob into the repository, returns an RJGit::Blob
tree = Tree.new_from_hashmap(repo, {"newblob" => "contents", "newtree" => { "otherblob" => "this blob is contained in the tree 'newtree'" } } ) # Constructs the tree and its children based on the hashmap and inserts it into the repository, returning an RJGit::Tree. Tree.new_from_hashmap takes an RJGit::Tree as an optional third argument, in which case the new tree will consist of the children of that Tree *plus* the contents of the hashmap.
```

### Committing and adding branches to repositories, 'porcelain' style (only works with non-bare repos)
```ruby
repo.create_branch('new_branch') # Similarly for deleting, renaming
repo.checkout('new_branch')
repo.add('new_file.txt') # Similarly for removing
repo.commit('My message')
repo.update_ref(commit) # Fast forward HEAD (or another ref) to the commit just created
```

### Committing and adding branches to repositories, 'plumbing' style (also works with bare repos)
```ruby
repo = repo.new("repo.git")
tree = Tree.new_from_hashmap(repo, {"newblob" => "contents"}, repo.head.tree ) # As above, use the current head commit's tree as a starting point and add "newblob"
actor = RJGit::Actor.new("test", "test@repotag.org")
commit = Commit.new_with_tree(repo, tree, "My commit message", actor) # Create a new commit with tree as base tree
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

Running RSpec tests (the recommended way)
---------------

1. Start the nailgun server
```
jruby --ng-server &
```
1. Run rake against the nailgun instance
```
jruby --ng -S rake
```

Authors
-------

RJGit is being developed by Team Repotag:

- [Maarten Engelen](https://github.com/maarten)
- [Bart Kamphorst](https://github.com/bartkamphorst)
- [Dawa Ometto](https://github.com/dometto)
- [Arlette van Wissen](https://github.com/arlettevanwissen)
- [Steven Woudenberg](https://github.com/stevenwoudenberg)

With special thanks to:
- [Patrick Pepels](https://github.com/bluedread)


License
-------
Copyright (c) 2011 - 2022, Team Repotag

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
