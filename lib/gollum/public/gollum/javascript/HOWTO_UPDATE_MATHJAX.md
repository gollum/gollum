# How to update MathJax

Our intention is to bundle a SLIM MathJax in gollum, so that gollum can work
offline with latex equations without bloating the gollum release tarball.

1. Clone the customized mathjax-cleaner from
   https://github.com/programfan/mathjax-cleaner

      git clone https://github.com/programfan/MathJax-grunt-cleaner

2. Install node, npm and grunt. Most of the time the package manager is
   enough. In case the package manager does not yet provide these packages,
   follow the instructions on https://www.gruntjs.net.

3. Install mathjax-cleaner dependencies.

      cd MathJax-grunt-cleaner && npm install 

4. Download latest mathjax release from
   https://github.com/mathjax/mathjax/releases and unzip to the
   directory of MathJax-grunt-cleaner.

5. Prepare grunt environments

      cp Gruntfile.js MathJax-x.y.z
      cp -r node_modules MathJax-x.y.z

6. Slimify mathjax

      cd MathJax-x.y.z && grunt && cd ..
      
7. Remove old mathjax (careful!)

     rm -rf ${GOLLUM_ROOT}/lib/gollum/public/gollum/javascript/MathJax

8. Replace bundled mathjax with newly generated one

      cp MathJax-x.y.z ${GOLLUM_ROOT}/lib/gollum/public/gollum/javascript/MathJax

9. Update mathjax version in ${GOLLUM_ROOT}/lib/gollum/templates/layout.mustache

