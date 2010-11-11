/*
 *  ../SourceForge/trunk/mathjax/jax/output/HTML-CSS/autoload/ms.js
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
  ['(','function(','a){var b="1.0";a.ms.Augment({toHTML:',1,'d){d=this.HTMLhandleSize(this.HTMLcreateSpan(d));var c=this.getValues("lquote","rquote");var f=this.data.join("");var e=[];if(c.lquote','.length===1){e.push(this.HTMLquoteRegExp(c.','lquote))}if(c.rquote',5,'rquote))}if(e.length){f=f.replace(RegExp("("+e.join("|")+")","g"),"\\\\$1")}this.HTMLhandleVariant(d,this.HTMLgetVariant(),c.lquote+f+c.rquote);this.HTMLhandleSpace(d);this.HTMLhandleColor(d);return d},HTMLquoteRegExp:',1,'c){return c.replace(/([.*+?|{}()\\[\\]\\\\])/g,"\\\\$1")}});a.ms.prototype.defaults.fontfamily="monospace";MathJax.Hub.Startup.signal.Post("HTML-CSS ms Ready")})(MathJax.ElementJax.mml);MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].autoloadDir+"/ms.js");']
]);

