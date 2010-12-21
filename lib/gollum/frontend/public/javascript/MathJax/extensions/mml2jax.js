/*
 *  ../SourceForge/trunk/mathjax/extensions/mml2jax.js
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
  ['MathJax.Extension.mml2jax','={varsion:"1.0.1",config:{element:null,preview:"alttext"},MMLnamespace:"http://www.w3.org/1998/Math/MathML",','PreProcess',':function(','b){if(!','this.configured','){','MathJax.Hub.','Insert(','this.config',',(',7,'config.','mml2jax||{}));if(',9,'.Augment','){',7,8,'this,',9,15,')}',5,'=true}if(typeof(b)==="string"){b=document.getElementById(b)}if(!b){b=',9,'.element||document.body}var c=b.getElementsByTagName("math"),a;if(c.length===0&&','b.getElementsByTagNameNS','){c=',27,'(this.MMLnamespace,"math")}if(this.','msieMathTagBug','){','for(a=c.length-1;a>=0;a--){','if(c[a].nodeName==="MATH"){this.','msieProcessMath','(c[a])}else{','this.ProcessMath(c[a','])}}}else{',33,37,'])}}},ProcessMath',3,'e){var d','=e.parentNode;var a=document.createElement("script");a.type="math/mml";','d','.insertBefore(','a,e);if(this.msieScriptBug){var b=e.outerHTML;b=b.replace(/<\\?import .*?>/,"").replace(/<\\?xml:namespace .*?\\/>/,"");b=b.replace(/<(\\/?)m:/g,"<$1").replace(/&nbsp;/g,"&#xA0;");a.text=b;d.removeChild(e)}else{var ','c=MathJax.HTML.Element("span','");c.appendChild(e);MathJax.HTML.addText(a,c.innerHTML)}','if(this.config.preview!=="none"){this.createPreview(e,a)}},',35,3,'e){var c',44,'c',46,'a,e);var b="";while(e&&','e.nodeName','!=="/MATH"){if(',58,'==="#text"||',58,'==="#comment"){b+=e.nodeValue.replace(/&/g,"&#x26;").replace(/</g,"&lt;").replace(/>/g,"&gt;")}else{b+=this.','toLowerCase','(e.outerHTML)}var d=e;e=e.nextSibling;d','.parentNode.removeChild(','d)}if(e&&',58,'==="/MATH"){e',66,'e)}a.text=b+"</math>";',50,64,3,'b){var d=b.split(/"/);for(var c=0,a=d.length;c<a;c+=2){d[c]=d[c].',64,'()}return d.join(\'"\')},createPreview',3,'b,a){var c;if(',9,'.preview','==="alttext"){var d=b.getAttribute("alttext");if(d!=null){c=[this.filterText(d)]}}else{if(',9,81,' instanceof Array){c=',9,81,'}}if(c){',48,'",{className:',7,12,'preRemoveClass},c);a.parentNode',46,'c,a)}},filterText',3,'a){return a}};',7,'Browser.Select({MSIE',3,'a){',7,8,0,',{msieScriptBug:true,',31,':true})}});',7,'Register.PreProcessor(["',2,'",',0,']);MathJax.Ajax.loadComplete("[MathJax]/extensions/mml2jax.js");']
]);

