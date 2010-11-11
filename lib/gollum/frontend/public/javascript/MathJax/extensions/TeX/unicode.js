/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/unicode.js
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
  ['MathJax.Extension["TeX/unicode','"]={version:"1.0",unicode:{},config:','MathJax.Hub.','Insert({fonts:"STIXGeneral,\'Arial Unicode MS\'"},((',2,'config.TeX||{}).unicode||{}))};','MathJax.Hub.Register.StartupHook("','TeX',' Jax Ready",function(){var ','d=MathJax.InputJax.TeX;var ','a=MathJax.','ElementJax.mml;var c=',0,'"].config.fonts;var b=',0,'"].unicode;','d.Definitions.macros.unicode="Unicode";d.Parse.Augment({Unicode:function(f){var j','=this.GetBrackets(f','),e;if(j){j=j.replace(/ /g,"");if(j.match(/^(\\','d+(\\.\\d*)?|\\.\\d','+),(\\',19,'+)$/)){j=j.split(/,/);e',17,')}else{e=j;j=null}}var k=this.trimSpaces(this.GetArgument(f)),i=parseInt(k.match(/^x/)?"0"+k:k);b[i]=[800,200,500,0,500,{isUnknown:true,isUnicode:true,font:c}];if(j){b[i][0',']=Math.floor(j[','0]*1000);b[i][1',25,'1]*1000)}var g=this.stack.env.font,h={};if(e){h.fontfamily=e;if(g){if(g.match(/bold/)){h.fontweight="bold"}if(g.match(/italic/)){h.fontstyle="italic"}}b[i][5].font=e+","+c}else{if(g){h.mathvariant=g}}this.Push(a.mtext(a.entity("#"+k)).With(h))}})});',6,'HTML-CSS',8,10,'OutputJax["',30,'"];var c=',0,15,'var b=a.lookupChar;a.Augment({lookupChar:function(e,f){var d=b.call(this,e,f);if(d[f][5]&&d[f][5].isUnknown&&c[f]){d[f]=c[f]}return d}});',2,'Startup.signal.Post("TeX unicode Ready")});MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/unicode.js");']
]);

