/*
 *  ../SourceForge/trunk/mathjax/extensions/jsMath2jax.js
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
  ['MathJax.Extension.jsMath2jax','={version:"1.0",config:{element:null,','preview',':"TeX"},','PreProcess',':function(','b){if(!','this.configured','){','MathJax.Hub.','Insert(this','.config,(',9,'config.jsMath2jax||{}));if(','this.config.','Augment','){',9,10,',',14,15,')}','if(typeof(',14,'previewTeX',')!=="undefined"&&!',14,25,'){',14,2,'="none"}this.previewClass=',9,'config.preRemoveClass',';',7,'=true}',23,'b)==="string"){b=document.getElementById(b)}if(!b){b=',14,'element||document.body}var c','=b.getElementsByTagName("','span"),a;for(a=c','.length-1;a>=0;a--){if(String(','c','[a].className).match(/\\bmath\\b/)){this.ConvertMath(','c[a],"")}}var d',42,'div");for(a=d',44,'d',46,'d[a],"; mode=display")}}},ConvertMath',5,'c,d){var b=c','.parentNode',',a=this.','createMathTag','(d,c.innerHTML);if(c.nextSibling){b','.insertBefore(','a,c.nextSibling)}else{b.appendChild(a)}if(',14,2,'!=="none"){this.','createPreview','(c)}b.removeChild(c)},',65,5,'a){var b;if(',14,2,'==="TeX"){b=[this.filterTeX(a.innerHTML)]}else{if(',14,2,' instanceof Array){b=',14,2,'}}if(b){b=MathJax.HTML.Element("span",{className:',9,34,'},b);a',56,60,'b,a)}},',58,5,'c,b){var a=document.createElement("script");a.type="math/tex"+c;if(',9,'Browser.isMSIE){a.text=b}else{a.appendChild(document.createTextNode(b))}return a},filterTeX',5,'a){return a}};',9,'Register.PreProcessor(["',4,'",',0,']);MathJax.Ajax.loadComplete("[MathJax]/extensions/jsMath2jax.js");']
]);

