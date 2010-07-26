/*************************************************************
 *
 *  MathJax/config/MathJax.js
 *
 *  This configuration file is loaded when there is no explicit
 *  configuration script in the <script> tag that loads MathJax.js
 *
 *  Use it to customize the MathJax settings.  See comments below.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009-10 Design Science, Inc.
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

MathJax.Hub.Config({

  //
  //  A comma-separated list of configuration files to load
  //  when MathJax starts up.  E.g., to define local macros, etc.
  //  teh default directory is the MathJax/config directory.
  //  
  //  Example:    config: ["local/local.js"],
  //  Example:    config: ["local/local.js","MMLtoHTML.js"],
  //
  config: [],
  
  //
  //  A comma-separated list of CSS stylesheet files to be loaded
  //  when MathJax starts up.  The default directory is the
  //  MathJax/config directory.
  // 
  //  Example:    styleSheets: ["MathJax.css"],
  //
  styleSheets: [],
  
  //
  //  Styles to be defined dynamically at startup time.
  //  
  //  Example:
  //      styles: {
  //        ".MathJax .merror": {
  //          color: "blue",
  //          "background-color": "green"
  //        }
  //      },
  //
  styles: {},
  
  //
  //  A comma-separated list of input and output jax to initialize at startup.
  //  Their main code is only loaded when they are actually used, so it is not
  //  inefficient to include jax that are not actually used on the page.  These
  //  are found in the MathJax/jax directory.
  //  
  jax: ["input/TeX","output/HTML-CSS"],
  
  //
  //  A comma-separated list of extensions to load at startup.  The default
  //  directory is MathJax/extensions.
  //  
  //  Example:    extensions: ["tex2jax.js","TeX/AMSmath.js","TeX/AMSsymbols.js"],
  //
  extensions: ["tex2jax.js"],
  
  //
  //  Comma-separated lists of .js and .css files to load at startup that depend
  //  on the browser being used.  The default directory is MathJax/config/browsers.
  //
  browser: {
    MSIE: [],
    Chrome: [],
    Safari: [],
    Firefox: [],
    Opera: []
  },
  
  //
  //  Patterns to remove from before and after math script tags.  If you are not
  //  using one of the preprocessors (e.g., tex2jax), you need to insert something
  //  etra into your HTML file in order to avoid a bug in Internet Explorer (IE
  //  removes spaces from the DOM that it things are redundent, and since a SCRIPT
  //  tag usually doesn't add content to the page, if there is a space before and after
  //  a MathJax SCRIPT tag, IE will remove the first space.  When MathJax inserts
  //  the typeset mathematics, this means there will be no space before it and the
  //  preceeding text.  In order to avoid this, you should include some "guard characters"
  //  before or after the math SCRIPT tag; define the patterns you want to use below.
  //  Note that these are actually regular expressions, so you will need to quote
  //  special characters.  If both are defined, both must be present in order to be
  //  removed.  See also the preRemoveClass comments below.
  //  
  //  Example:
  //      preJax: "\\\\",  // makes a double backslash the preJax text
  //    or
  //      preJax:  "\[\[", // jax scripts must be enclosed in double brackets
  //      postJax: "\]\]",
  //
  preJax: null,
  postJax: null,
  
  //
  //  The CSS class for a math preview to be removed preceeding a MathJax SCRIPT tag.
  //  This allows you to include a math preview in a form that will be displayed prior
  //  to MathJax loading performing its typesetting.  It also avoids the Internet Explorer
  //  space-removal bug, and can be used in place of preJax and postJax if that is more
  //  convenient.  For example
  //  
  //      <span class="MathJax_Preview">[math]</span><script type="math/tex">...</script>
  //
  //  would display "[math]" in place of the math until MathJax is able to typeset it.
  //
  preRemoveClass: "MathJax_Preview",
  
  //
  //  This value controls whether the "Processing Math: nn%" message are displayed
  //  in the lower left-hand corner.  Set to "false" to prevent those messages (though
  //  file loading and other messages will still be shown).
  //
  showProcessingMessages: true,
  
  //
  //  Normally MathJax will perform its starup commands (loading of
  //  configuration, styles, jax, and so on) as soon as it can.  If you
  //  expect to be doing additional configuration on the page, however, you
  //  may want to have it wait until the page's onload hander is called.  If so,
  //  set this to "onload".
  //
  delayStartupUntil: "none",

  //
  //  Normally MathJax will typeset the mathematics on the page as soon as
  //  the page is loaded.  If you want to delay that process, in which case
  //  you will need to call MathJax.Hub.Typeset() yourself by hand, set
  //  this value to true.
  //
  skipStartupTypeset: false,
  
  //============================================================================
  //
  //  These parameters control the tex2jax preprocessor (when you have included
  //  "tex2jax.js" in the extensions list above).
  //
  tex2jax: {

    //
    //  The Id of the element to be processed (defaults to full document)
    //
    element: null,

    //
    //  The delimiters that surround in-line math expressions.  The first in each
    //  pair is the initial delimiter and the second is the terminal delimiter.
    //  Comment out any that you don't want, but be sure there is no extra
    //  comma at the end of the last item in the list -- some browsers won't
    //  be able to handle that.
    //
    inlineMath: [
//    ['$','$'],      // uncomment this for standard TeX math delimiters
      ['\\(','\\)']
    ],

    //
    //  The delimiters that surround displayed math expressions.  The first in each
    //  pair is the initial delimiter and the second is the terminal delimiter.
    //  Comment out any that you don't want, but be sure there is no extra
    //  comma at the end of the last item in the list -- some browsers won't
    //  be able to handle that.
    //
    displayMath: [
      ['$$','$$'],
      ['\\[','\\]']
    ],

    //
    //  Set to "true" to allow \$ to produce a dollar without starting in-line
    //  math mode.  If you uncomment the ['$','$'] line above, you should change
    //  this to true so that you can insert plain dollar signs into your documents
    //
    processEscapes: false,

    //
    //  Controls whether tex2jax processes LaTeX environments outside of math
    //  mode.  Set to "false" to prevent processing of environments except within
    //  math mode.
    //
    processEnvironments: true,

    //
    //  Controls whether tex2jax inserts MathJax_Preview spans so that the TeX
    //  code is visible until it is processed by MathJax.  Set to "false" to prevent
    //  the previews from being inserted (the math will simply disappear until it is
    //  typeset).
    //  
    previewTeX: true
    
  },
  
  //============================================================================
  //
  //  These parameters control the jsMath2jax preprocessor (when you have included
  //  "jsMath2jax.js" in the extensions list above).
  //
  jsMath2jax: {
    //
    //  Controls whether jsMath2tex inserts MathJax_Preview elements so that
    //  the TeX code is visible until it is processed by MathJax.  Set to "false"
    //  to prevent previews from being inserted (the math will simply disappear
    //  until it is typeset).
    //
    previewTeX: true
  },

  //============================================================================
  //
  //  These parameters control the TeX input jax.
  //
  TeX: {

    //
    //  This specifies the side on which \tag{} macros will place the tags.
    //  Set to "left" to place on the left-hand side.
    //
    TagSide: "right",
    
    //
    //  This is the amound of indentation (from right or left) for the tags.
    //
    TagIndent: ".8em",
    
    //
    //  This is the width to use for the multline environment
    //
    MultLineWidth: "85%"
  },

  //============================================================================
  //
  //  These parameters control the MathML inupt jax.
  //
  MathML: {
    //
    //  This specifies whether to use TeX spacing or MathML spacing when the
    //  HTML-CSS output jax is used.
    //
    useMathMLspacing: false
  },
  
  //============================================================================
  //
  //  These parameters control the HTML-CSS output jax.
  //
  "HTML-CSS": {
    
    //
    //  This controls the global scaling of mathematics as compared to the 
    //  surrounding text.  Values between 100 and 133 are usually good choices.
    //
    scale: 100,
    
    //
    //  This is a list of the fonts available to MathJax in the
    //  MathJax/Fonts/HTML-CSS directory.  If you don't want MathJax
    //  to use one of these fonts (when available on the user's computer),
    //  remove it from the list.  Use an empty list to force the use of
    //  web fonts (or image fonts).
    //
    availableFonts: ["STIX","TeX"],
    
    //
    //  This is the preferred font to use when more than one of those
    //  listed above is available.
    //
    preferredFont: "TeX",
    
    //
    //  This is the web-based font to use when none of the fonts listed
    //  above are available on the user's computer.  Note that currently
    //  only the TeX font is available in a web-based form.  Set this to
    //  
    //      webFont: null,
    //
    //  if you want to prevent the use of web-based fonts.
    //
    webFont: "TeX",
    
    //
    //  This is the font to use for image fallback mode (when none of the
    //  fonts listed above are available and the browser doesn't support
    //  web-fonts via the @font-face CSS directive).  Note that currently
    //  only the TeX font is available as an image font.  Set this to
    //
    //      imageFont: null,
    //  
    //  if you want to prevent the use of image fonts (e.g., you have not
    //  installed the image fonts on your server).  In this case, only
    //  browsers that support web-based fonts will be able to view your pages
    //  without having the fonts installed on the client computer.  The browsers
    //  that support web-based fonts include: IE6 and later, Chrome, Safari3.1
    //  and above, Firefox3.5 and later, and Opera10 and later.  Note that
    //  Firefox3.0 is NOT on this list, so without image fonts, FF3.0 users
    //  will be required to to download and install either the STIX fonts or the
    //  MathJax TeX fonts.
    //
    imageFont: "TeX",

    //
    //  This allows you to define or modify the styles used to display
    //  various math elements created by MathJax.
    //  
    //  Example:
    //      styles: {
    //        ".MathJax_Display": {
    //          "text-align": "left",        // left aligned displayed math
    //          "margin-left": "3em",        //   with 3em indentation
    //        },
    //        ".MathJax_Preview": {
    //          "font-size": "80%",          // preview uses a smaller font
    //          color: "red"                 //    and is in red
    //        }
    //      }
    //
    styles: {}
  },
  
  //============================================================================
  //
  //  These parameters control the MMLorHTML configuration file.
  //  NOTE:  if you add MMLorHTML.js to the config array above,
  //  you must REMOVE the output jax from the jax array.
  //
  MMLorHTML: {
    //
    //  The output jax that is to be preferred when both are possible
    //  (set to "MML" for native MathML, "HTML" for MathJax's HTML-CSS output jax).
    //
    prefer: "HTML"
  }
});

MathJax.Ajax.loadComplete("[MathJax]/config/MathJax.js");
