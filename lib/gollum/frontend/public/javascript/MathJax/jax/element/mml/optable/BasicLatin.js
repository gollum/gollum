/*
 *  ../SourceForge/trunk/mathjax/jax/element/mml/optable/BasicLatin.js
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
  ['(function(a){var c=a.mo.OPTYPES;var b=a.TEXCLASS;MathJax.Hub.Insert(a.mo.prototype,{OPTABLE:{postfix:{"!!":[1,0,b.BIN],"\'":c.ACCENT,"++":[0,0,b.BIN],"--":[0,0,b.BIN],"..":[0,0,b.BIN],"...":c.ORD},infix:{"!=":c.BIN4,"&&":c.BIN4,"**":[1,1,b.BIN],"*=":c.BIN4,"+=":c.BIN4,"-=":c.BIN4,"->":c.BIN4,"//":c.BIN4,"/=":c.BIN4,":=":c.BIN4,"<=":c.BIN4,"<>":[1,1,b.BIN],"==":c.BIN4,">=":c.BIN4,"@":c.ORD11,"||":c.BIN3}}});MathJax.Ajax.loadComplete(a.optableDir+"/BasicLatin.js")})(MathJax.ElementJax.mml);']
]);

