# How to update MathJax

Our intention is to bundle a SLIM MathJax in gollum, so that gollum can work
offline with latex equations without bloating the gollum release tarball. We do this by removing the combined component files that we don't need: all we need are `tex-mml-chtml.js` and `tex-chtml-full-speech.js` (for accessibility). **From the root of the gollum repository**:

1. Start by cloning the latest MathJax: `git clone https://github.com/mathjax/MathJax.git /tmp/MathJax`
2. Remove old mathjax: `git rm -r lib/gollum/public/gollum/javascript/MathJax/*`
3. `cp -r /tmp/MathJax/es5/* lib/gollum/public/gollum/javascript/MathJax/`
4. Then remove the following files:
  * lib/gollum/public/gollum/javascript/MathJax/mml-chtml.js
  * lib/gollum/public/gollum/javascript/MathJax/mml-svg.js
  * lib/gollum/public/gollum/javascript/MathJax/tex-chtml-full.js
  * lib/gollum/public/gollum/javascript/MathJax/tex-chtml.js
  * lib/gollum/public/gollum/javascript/MathJax/tex-mml-svg.js
  * lib/gollum/public/gollum/javascript/MathJax/tex-svg-full.js
  * lib/gollum/public/gollum/javascript/MathJax/tex-svg.js
5. `git add lib/gollum/public/gollum/javascript/MathJax`

Oneliner for removing the files:

`git rm lib/gollum/public/gollum/javascript/MathJax/mml-chtml.js  lib/gollum/public/gollum/javascript/MathJax/mml-svg.js lib/gollum/public/gollum/javascript/MathJax/tex-chtml-full.js lib/gollum/public/gollum/javascript/MathJax/tex-chtml.js lib/gollum/public/gollum/javascript/MathJax/tex-mml-svg.js  lib/gollum/public/gollum/javascript/MathJax/tex-svg-full.js lib/gollum/public/gollum/javascript/MathJax/tex-svg.js`