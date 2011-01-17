/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/mathchoice.js
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
  ['MathJax.','Hub.Register.StartupHook("TeX Jax Ready",function(){var c="1.0";var a=',0,'ElementJax.mml;var d=',0,'InputJax.TeX;var b=d.Definitions;b.macros.','mathchoice','="','MathChoice','";d.Parse.Augment({',8,':function','(f){var i','=this.ParseArg(f','),e',13,'),g',13,'),h',13,');this.Push(a.','TeXmathchoice','(i,e,g,h))}});a.',21,'=a.mbase.Subclass({type:"',21,'",choice',11,'(){var e=this.getValues("displaystyle","','scriptlevel','");if(e.',29,'>0){return Math.min(3,e.',29,'+1)}return(e.displaystyle?0:1)},','setTeXclass',11,'(e){return this.','Core().',35,'(e)},','isSpacelike',':function(){return this.',38,41,'()},','isEmbellished',42,38,46,'()},Core',42,'data[this.choice()]},toHTML',11,'(e){e=this.HTMLcreateSpan(e);e.bbox=this.',38,'toHTML(e).bbox;return e}});',0,'Hub.Startup.signal.Post("TeX ',6,' Ready")});',0,'Ajax.loadComplete("[MathJax]/extensions/TeX/',6,'.js");']
]);

