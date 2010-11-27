/*
 *  ../SourceForge/trunk/mathjax/extensions/toMathML.js
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
  ['MathJax.Hub.Register.','LoadHook("[','MathJax',']/jax/element/mml/jax.js",','function(){','var b="1.0";var a=',2,'.ElementJax.mml;a.mbase','.Augment({toMathML:function(','k){var g=(this.inferred&&this.parent.inferRow);if(k==null){k=""}var e','=this.','type,d',10,'MathMLattributes','();if(e==="mspace"){','return k+"<"+e+d','+" />"}','var j=[];var h=(','this.isToken','?"":k+(g?"":"  "));for(var f=0,c',10,'data.length;f<c;f++){if(','this.data[','f]){j.push(',22,'f].toMathML(h))}else{if(!',18,'){j.push(','h+"<mrow />")}}}if(',18,'){',15,'+">"+j.join("")+"</"+e+">"}if(g){return j.join("\\n")}if(j.length===0||(j.length===1&&j[0]==="")){',15,16,15,'+">\\n"+j.join("\\n")+"\\n"+k+"</"+e+">"},',13,':',4,'var j=[],g',10,'defaults;var c',10,'copyAttributes',',l',10,'skipAttributes',';','if(this.type==="','math"){j.push(\'xmlns="http://www.w3.org/1998/Math/MathML"\')}',49,'mstyle"){g=a.math.prototype.defaults}for(var d in g){if(!l[d]&&g.hasOwnProperty(d)){var e=(d==="open"||d==="close");if(this[d]!=null&&(e||this[d]!==g[d])){var k=this[d];delete this[d];if(e||this.Get(d)!==k',27,'d+\'="\'+','this.quoteHTML(','k)+\'"\')}this[d]=k}}}for(var h=0,f=c.length;h<f;h++){if(this[c[h]]!=null',27,'c[h]+\'="\'+',55,'this[c[h]])+\'"\')}}if(j.length){return" "+j.join(" ")}else{return""}},',44,':["fontfamily","fontsize","fontweight","fontstyle","color","background","id","class","href","style"],',47,':{texClass:1,useHeight:1,texprimestyle:1},quoteHTML:function(e){e=String(e).split("");for(var f=0,d=e.length;f<d;f++){var h=e[f].charCodeAt(0);if(h<32||h>126){e[f]="&#x"+h.toString(16).toUpperCase()+";"}else{var g={"&":"&amp;","<":"&lt;",">":"&gt;",\'"\':"&quot;"}[e[f]];if(g){e[f]=g}}}return e.join("")}});a.msubsup',8,'h){var e=this.type;if(this.data[this.','sup',']==null){e="','msub"}if(',22,'this.sub',68,'msup','"}var d=this.MathMLattributes();delete this.data[0].inferred;var g=[];for(var f=0,c=this.data.length;f<c;f++){if(this.data[f]){g.push(this.data[f].toMathML(h+"  "))}}return h+"<"+e+d+">\\n"+g.join("\\n")+"\\n"+h+"</"+e+">"}});a.','munderover',8,66,'under',68,'mover"}if(',22,'this.over',68,'munder',74,'TeXAtom',8,'c){return',' c+"<mrow>\\n"+',22,'0].toMathML(c+"  ")+"\\n"+c+"</mrow>"}});a.chars',8,88,'(c||"")+',55,'this.toString','())}});a.entity',8,88,'(c||"")+"&"+',22,'0]+";<!-- "+',96,'()+" -->"}});',0,'StartupHook("TeX mathchoice Ready",',4,'a.TeXmathchoice',8,88,' this.Core().toMathML(c)}})});',2,'.Hub.Startup.signal.Post("toMathML Ready")});',2,'.Ajax.loadComplete("[',2,']/extensions/toMathML.js");']
]);

