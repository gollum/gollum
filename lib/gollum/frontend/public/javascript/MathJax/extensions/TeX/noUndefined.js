/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/noUndefined.js
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
  ['MathJax.Extension["TeX/noUndefined','"]={version:"1.0",config:','MathJax.Hub.','Insert({attributes:{mathcolor:"red"}},((',2,'config.TeX||{}).','noUndefined','||{}))};',2,'Register.StartupHook("TeX Jax Ready",function(){var b=',0,'"].config;var a=MathJax.ElementJax.mml;MathJax.InputJax.TeX.Parse.Augment({csUndefined:function(c){this.Push(a.mtext(c).With(b.attributes))}});',2,'Startup.signal.Post("TeX ',6,' Ready")});MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/',6,'.js");']
]);

