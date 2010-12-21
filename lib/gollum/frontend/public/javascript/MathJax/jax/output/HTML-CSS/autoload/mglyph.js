/*
 *  ../SourceForge/trunk/mathjax/jax/output/HTML-CSS/autoload/mglyph.js
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
  ['(','function','(a,b){var c="1.0";a.mglyph.Augment({toHTML:',1,'(i,h){var k=i,f=this.getValues("src","','width','","','height','","','valign','","alt"),j;i=this.HTMLcreateSpan(i);','if(f.','src===""){var g=this.Get("index");if(g){h=this.HTMLgetVariant();var e=h.defaultFont;if(e){e.noStyleChar=true;e.testString=','String.fromCharCode(g',')+"ABCabc";if(b.Font.testFont(e)){this.HTMLhandleVariant(i,h,',13,'))}else{',11,'alt===""){f.alt="Bad font: "+e.family}j=a.merror(f.alt',').With({mathsize:"75%"});this.Append(j);j.toHTML(i);this.data.pop();i.bbox=j.HTMLspanElement().bbox','}}}}else{','if(!this.img){this.img=a.mglyph.GLYPH[f.src',']}',21,']={img:new Image(),status:"pending"};var d=','this.img.img',';d.onload','=MathJax.Callback(["','HTMLimgLoaded','",this]);d.','onerror',27,'HTMLimgError',29,'src=f.src;MathJax.Hub.RestartAfter(d.onload)}if(','this.img.status','!=="OK"){j=a.merror("Bad mglyph: "+f.src',19,'}else{d=b.addElement(i,"img",{src:f.src,alt:f.alt,title:f.alt});',11,5,'){if(String(f.',5,').match(/^\\s*-?\\d+\\s*$/)){f.',5,'+="px"}d.style.',5,'=b.Em(','b.length2em(f.',5,',',25,'.',5,'/b.em))}',11,7,41,7,43,7,45,7,47,48,7,',',25,'.',7,54,'i.bbox.w=i.bbox.rw=d.offsetWidth/b.em;i.bbox.h=d.offsetHeight/b.em;',11,9,41,9,43,9,'+="px"}i.bbox.d=-',48,9,',',25,'.',7,'/b.em);d.style.verticalAlign=b.Em(-i.bbox.d);i.bbox.h-=i.bbox.d}}}if(!k.bbox){k.bbox={w:i.bbox.w,h:i.bbox.h,d:i.bbox.d,rw:i.bbox.rw,lw:i.bbox.lw}}else{if(i.bbox){k.bbox.w+=i.bbox.w;if(k.bbox.w>k.bbox.rw){k.bbox.rw=k.bbox.w}if(i.bbox.h>k.bbox.h){k.bbox.h=i.bbox.h}if(i.bbox.d>k.bbox.d){k.bbox.d=i.bbox.d}}}this.HTMLhandleSpace(i);this.HTMLhandleColor(i);return i},',28,':',1,'(e,d){if(typeof(e)==="string"){d=e}',35,'=(d||"OK")},',32,':',1,'(){',25,'.onload("error")}},{GLYPH:{}});MathJax.Hub.Startup.signal.Post("HTML-CSS mglyph Ready");MathJax.Ajax.loadComplete(b.autoloadDir+"/mglyph.js")})(MathJax.ElementJax.mml,MathJax.OutputJax["HTML-CSS"]);']
]);

