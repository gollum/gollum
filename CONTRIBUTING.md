# Contributing to Gollum

Thanks for your interest in the gollum project!

## Submitting an Issue

Please note that the issue tracker is meant for:

1. Bug reports.
2. Feature requests.

If your have problems using or installing the software which stem from bugs in the software or a lack of documentation, we are always happy to help out! However, **for ordinary usage questions, please consider asking elsewhere**, for instance on [StackOverflow](http://stackoverflow.com/questions/tagged/gollum-wiki).

Gollum supports [custom macros](https://github.com/gollum/gollum/wiki#macros) for the creation of additional wiki markup tags. Please **do not** use this tracker to request macros specific to your situation. However, if you have or are working on a macro that you think may be useful to more users, you can share it as a GitHub [gist](https://gist.github.com) and link to it in the [wiki](https://github.com/gollum/gollum/wiki/Custom-macros).

Before submitting an issue, **please carefully look through the following places** to make sure your problem is not already addressed:

1. The issue tracker.
1. The [README](https://github.com/gollum/gollum/blob/master/README.md).
1. The project's [wiki](https://github.com/gollum/gollum/wiki).

Security vulnerabilities can be reported directly to the maintainers using these GPG keys:

* [@dometto](https://keys.openpgp.org/vks/v1/by-fingerprint/02354CC9F820B52CC2791979BB8CCC95FD83B795)

Lastly, please **consider helping out** by opening a Pull Request!

## Triaging Issues [![Open Source Helpers](https://www.codetriage.com/gollum/gollum/badges/users.svg)](https://www.codetriage.com/gollum/gollum)

You can triage issues which may include reproducing bug reports or asking for vital information, such as version numbers or reproduction instructions. If you would like to start triaging issues, one easy way to get started is to [subscribe to gollum on CodeTriage](https://www.codetriage.com/gollum/gollum).


## Opening a Pull Request

Pull Requests fixing bugs, implementing new features, or updating documentation and dependencies are all very welcome! If you would like to help out with the project, you can pick an open issue from the issue tracker. We're more than happy to help you get started! Here's how you can proceed:

1. Fork and clone Gollum.
2. Create a thoughtfully named topic branch to contain your changes.
3. If you haven't installed dependencies yet, navigate to your clone and execute:  
	```
	[sudo] bundle install
	```
4. Hack away.
5. Add your own tests and make sure they're all still passing.
6. If some of your changes deserve a mention on Gollum's home page, edit the README accordingly.
7. If necessary, rebase your commits into logical chunks, without errors.
8. Push the branch to your fork on GitHub.
9. Create a pull request for Gollum.

**Notes:**
* Do not change Gollum's version numbers, we will do that on our own.

### Running tests

1. Install [Bundler](http://bundler.io/).
2. Navigate to the cloned source of Gollum.
3. Install dependencies:  
	```
	[sudo] bundle install
	```
4. Run the tests:  
	```
	bundle exec rake test
	```
	
To profile slow tests, you can use `bundle exec rake test TESTOPTS="--verbose"`.

### Working with test repositories

An example of how to add a test file to the bare repository lotr.git.

```
mkdir tmp
cd tmp
git clone ../test/examples/lotr.git/
git log
echo "test" > test.md
git add .
git commit -am "Add test"
git push ../lotr.git/ master
```

## Updating static assets

This is necessary whenever changes have been made to the assets in `lib/gollum/public/gollum/javascript` (mostly SASS, CSS, and JS files), to ensure the changes are also present in the [released](#releasing-the-gem) version of the gem. Steps:

1. `git rm -r lib/gollum/public/assets`
1. `bundle exec rake precompile`
1. `git add lib/gollum/public/assets`
1. `git commit`

## Releasing the gem

Gollum uses [Semantic Versioning](http://semver.org/).

    x.y.z

For z releases:

```
rake bump
rake release
```

For x.y releases:

```
# First update VERSION in lib/gollum.rb and then:
rake gemspec
rake release
```
