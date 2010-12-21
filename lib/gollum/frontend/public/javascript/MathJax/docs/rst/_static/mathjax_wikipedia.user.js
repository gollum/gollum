// ==UserScript==
// @name           MathJax in Wikipedia
// @namespace      http://www.mathjax.org/
// @description    Insert MathJax into Wikipedia pages
// @include        http://en.wikipedia.org/wiki/*
// ==/UserScript==

if ((window.unsafeWindow == null ? window : unsafeWindow).MathJax == null) {
  //
  //  Replace the images with MathJax scripts of type math/tex
  //
  var images = document.getElementsByTagName('img');
  for (var i = images.length - 1; i >= 0; i--) {
    var img = images[i];
    if (img.className === "tex") {
      var script = document.createElement("script"); script.type = "math/tex";
      if (window.opera) {script.innerHTML = img.alt} else {script.text = img.alt}
      img.parentNode.replaceChild(script,img);
    }
  }
  //
  //  Load MathJax and have it process the page
  //
  var script = document.createElement("script");
  script.src = "http://www.yoursite.edu/MathJax/MathJax.js";  // put your URL here
  var config = 'MathJax.Hub.Config({' +
                 'config: ["MMLorHTML.js"],' +
                 'extensions:["TeX/noErrors.js","TeX/noUndefined.js",' +
                             '"TeX/AMSmath.js","TeX/AMSsymbols.js"],' +
                 'jax:["input/TeX"]' +
               '});' +
               'MathJax.Hub.Startup.onload()';
  if (window.opera) {script.innerHTML = config} else {script.text = config}
  document.getElementsByTagName("head")[0].appendChild(script);
}
