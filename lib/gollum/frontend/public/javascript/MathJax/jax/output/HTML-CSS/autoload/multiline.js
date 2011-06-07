/*
 *  ../SourceForge/trunk/mathjax/jax/output/HTML-CSS/autoload/multiline.js
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
  ['(function(a,b){var c="1.0";a.mbase.Augment({toHTMLmultiline:function(u,r){u=this.HTMLcreateSpan(u);if(!this.type!=="mrow"){u=this.HTMLhandleSize(u)}var g=b.createStack(u);var o=[],f=[],p','=-b.BIGDIMEN,','q',1,'v,t,s,k',';for(t=0,k=r.length-1;t<k;t++){','o[t]=b.createBox(g);for(v=r[t][0],s=r[t+1][0];v<s;v++){if(this.data[v]){this.data[v].toHTML(o[t])}}if(','this.data[r[t][','0]]){',7,'0',']].HTMLspanElement().style.','paddingLeft=""}if(',7,'s-1]]){',7,'s-1',11,'paddingRight=""}f[t]=','this.HTMLcomputeBBox(o[t],','null',',r[t][0],r[t+1][0',']);if(','o[t].bbox.','h>p){p=',23,'h}if(',23,'d>q){q=',23,'d}}var n=0,x=this.HTMLgetScale(),e=b.FONTDATA.baselineskip*x;var l=this,h;while(l.inferred||(l.parent&&l.parent.type==="mrow"&&l.parent.data.length===1)){l=l.parent}var w=(','l.type==="math','"||l.type==="mtd");l.isMultiline=true',5,'for(v=0,s=f[t].length;v<s;v++){f[t][v].HTMLstretchV(o[t],p,q)}if(f[t].length){',19,'true',21,'])}var d=r[t','][1].getValues("','indentalign","indentshift");d.','lineleading','=b.length2em(','r[t+1][1].Get("',41,'"),0.5);if(t===0){h=r[t+1',39,'indentalignfirst','","','indentshiftfirst','");d.ALIGN=h.',47,';d.SHIFT=h.',49,'}else{if(t===k-1){h=r[t',39,'indentalignlast','","','indentshiftlast',50,56,52,58,'}}if(d.ALIGN&&d.ALIGN!==','a.INDENTALIGN.','INDENTALIGN){','d.indentalign','=d.ALIGN}if(d.SHIFT&&d.SHIFT!==a.INDENTSHIFT.INDENTSHIFT){','d.indentshift','=d.SHIFT}if(',66,'==',64,'AUTO){',66,'=(w?this.','displayAlign:',64,'LEFT)}if(',68,'==="auto"||',68,'===""){',68,75,'displayIndent:"0")}',68,42,68,',0);if(',68,'&&',66,'!==',64,'CENTER){b.createBlank(o[t],',68,',(',66,'!==',64,'RIGHT));',23,'w+=',68,';',23,'rw+=',68,'}b.alignBox(o[t],',66,',n);if(t<k-1){n-=Math.max(e,',23,'d+o[t+1].bbox.h+d.',41,')}}if(w){g.style.width="100%";if(',31,'"){u.bbox.width="100%"}}this.HTMLhandleSpace(u);this.HTMLhandleColor(u);u.bbox.isMultiline=true;return u}});MathJax.Hub.Startup.signal.Post("HTML-CSS multiline Ready");MathJax.Ajax.loadComplete(b.autoloadDir+"/multiline.js")})(MathJax.ElementJax.mml,MathJax.OutputJax["HTML-CSS"]);']
]);

