/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/noErrors.js
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
  ['(function(){var c="1.0";','MathJax.Extension["TeX/noErrors','"]={version:c,config:','MathJax.Hub.','Insert({','multiLine',':true,','inlineDelimiters',':["",""],style:{"font-family":"serif","font-size":"80%","text-align":"left",color:"black",padding:"1px 3px",border:"1px solid"}},((',3,'config.TeX||{}).noErrors||{}))};var a=',1,'"].config;var ','b=String.fromCharCode(160);',3,'Config({TeX:{Augment:{formatError:function(f,e,g,d){var i=a.',7,';var h=(g||a.',5,');if(!g){e=i[0]+e+i[1]}if(h){e=e.replace(/ /g,b)}else{e=e.replace(/\\n/g," ")}return ','MathJax.ElementJax.mml','.merror','(e).With({isError',6,5,':h})}}},"','HTML-CSS','":{styles:{".','MathJax .merror','":',3,'Insert({"font-style":null,"background-color":null,"vertical-align":(',3,'Browser.isMSIE&&a.',5,'?"-2px":"")},a.style)}}})})();',3,'Register.StartupHook("',26,' Jax Ready",function(){var ','a=',20,';var b=MathJax.OutputJax["',26,'"];var c=a.math','.prototype.toHTML',';a.math','.Augment({toHTML:function(','d,e','){if(this.data[0]&&this.data[0].data[0]&&this.data[0].data[0].isError){return this.data[0].data[0].','toHTML','(d)}return c.call(this,d',',e)}});a',21,47,'j','){if(!this.isError){return ','a.mbase',45,'.call(this,','j)}j=this.HTMLcreateSpan(j);','if(this.',5,'){j','.style.display="inline-block','"}var l','=this.data[0].data[0].data.join("").split(/\\n/);for(var ','g=0,e=l.length;g<e;g++){b.addText(j,l[g]);if(g!==e-1){b.addElement(j,"br")}}var n=b.getHD(','j.parentNode','),d=b.getW(',68,');if(e>1){var k=(n.h+n.d)/2,h=b.TeX.x_height/2;var f=b.config.styles[".',28,'"]["font-size"];if(f&&f.match(/%/)){h*=parseInt(f)/100}',68,'.style.verticalAlign','=b.Em(n.d+(h-k));n.h=h+k;n.d=k-h}j.bbox={h:n.h,d:n.d,w:d,lw:0,rw:d};return j','}});MathJax.Hub.Startup.signal.Post("TeX noErrors Ready")});MathJax.','Hub.',37,'NativeMML',39,'b=',20,';var a=',1,12,'c=b.math','.prototype.toNativeMML',';b.math','.Augment({toNativeMML:function(','d',49,'toNativeMML',51,')}});b',21,90,'g',56,'b.mbase',88,59,'g)}g=','g.appendChild(document.','createElement("','span"));var h',66,'f=0,e=h.length;f<e;f++){',104,'createTextNode(h[f]));if(f!==e-1){',104,105,'br"))}}',61,5,'){g',64,'";if(e>1){g',75,'="middle"}}for(var j in a.style){if(a.style.hasOwnProperty(j)){var d=j.replace(/-./g,function(i){return i.charAt(1).toUpperCase()});g.style[d]=a.style[j]}}return g',77,'Ajax.loadComplete("[MathJax]/extensions/TeX/noErrors.js");']
]);

