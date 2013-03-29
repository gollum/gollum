JGit
=====

###A JRuby wrapper around the JGit library for manipulating Git repositories


Authors
-------

RJGit is being developed by Team Repotag:

- Maarten Engelen
- Bart Kamphorst
- Dawa Ometto
- Arlette van Wissen
- Steven Woudenberg

With special thanks to:
- Patrick Pepels

Installation
------------
Installing the rjgit gem requires the command:

$ gem install rjgit

#### Dependencies for using RJGit:
- JRuby 1.7.0 or higher
- mime-types 1.15 or higher

#### Dependencies for developing RJGIT:
- JRuby 1.7.0 or higher
- mime-types 1.15 or higher
- rspec 2.0 or higher
- simplecov

Usage
-----
The usage of the RJGit gem.

Initialize a repository on the filesystem:

```ruby
require "rjgit"
repo = Repo.new("repo.git")
```

...or create a new repository:

```ruby
repo = Repo.new("repo.git", :create => true)
```

Future features
---------------
Features which will be implemented in the near future

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
