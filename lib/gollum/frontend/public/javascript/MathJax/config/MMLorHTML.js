/*
 *  ../SourceForge/trunk/mathjax/config/MMLorHTML.js
 *  
 *  Copyright (c) 2010 Design Science, Inc.
 *
 *  Part of the MathJax library.
 *  See http://www.mathjax.org for details.
 * 
 *  Licensed under the Apache License, Version 2.0;
 *  you may not use this file except in compliance with the License.
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 */

MathJax.Unpack([
  ['(function(c){var i="1.0";var g=','MathJax.Hub','.Insert({prefer:{MSIE:"MML",Firefox:"MML",Opera:"HTML",other:"HTML"}},(',1,'.config.MMLorHTML||{}));var e={Firefox:3,Opera:9.52,MSIE:6,Chrome:0.3,Safari:2,Konqueror:4};var h=(c','.Browser','.version==="0.0"||','c.Browser.versionAtLeast','(e[c',5,']||0));var b;try{new ActiveXObject("MathPlayer.Factory.1");b=true}catch(d){b=false}var f=(c',5,'.isFirefox&&',7,'("1.5"))||(c',5,'.isMSIE&&b)||(c',5,'.isOpera&&',7,'("9.52"));var a=(g.prefer&&typeof(g.prefer)==="object"?g.prefer[',1,5,']||g.prefer.other||"HTML":g.prefer);if(h||f){if(f&&(a==="MML"||!h)){','c.config.jax.unshift("output/','NativeMML")}else{',24,'HTML-CSS")}}else{c.PreProcess','.disabled=true;','c.prepareScripts',28,'MathJax.Message.Set("Your browser does not support MathJax",null,4000);c.Startup.signal.Post("MathJax not supported")}})(',1,');MathJax.Ajax.loadComplete("[MathJax]/config/MMLorHTML.js");']
]);

