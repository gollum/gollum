# 6.0

# Breaking Changes

* Docker image: removed deprecated automatic activation of --mathjax. Pass '--math mathjax' to continue using mathjax, or '--math' to use KaTeX (see below).

## New features

* Add support for Mermaid diagrams (@dometto).
* Add support for downloading page sources with ?raw (@tstein).
* Add openssh client to docker images for ssh: repo support. (@jagerkin).
* Add support for mathematical typesetting using KaTeX (@dometto). Users can now choose between MathJax and KaTeX with the --math flag.

## Fixes & Improvements

* Fix (Docker image): add git configuration for `/wiki` as safe directory. #2006
