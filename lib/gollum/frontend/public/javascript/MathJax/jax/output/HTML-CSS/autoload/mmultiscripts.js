/*
 *  ../SourceForge/trunk/mathjax/jax/output/HTML-CSS/autoload/mmultiscripts.js
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
  ['(','function(','a,b){var c="1.0";a.','mmultiscripts','.Augment({toHTML:',1,'H,F,A){H=this.HTMLcreateSpan(H);var M=this.','HTMLgetScale();var ','k=b.createStack(H),f;var j=b.createBox(k);this.HTMLmeasureChild(this.base,j);if(','this.data[this.base',']){if(A!=null){b.Remeasured(',9,'].','HTMLstretchV','(j,F,A),j)}else{if(F!=null){b.Remeasured(',9,'].','HTMLstretchH','(j,F),j)}}}var K=b.TeX.x_height*M,z=b.TeX.scriptspace*M*0.75;var y=this.','HTMLgetScripts','(k,z);var l=y[0],e=y[1],o=y[2],i=y[3];var g=(','this.data[','1]||this).',7,'C=b.TeX.sup_drop*g,B=b.TeX.sub_drop*g;var w=j.bbox.h-C,n=j.bbox.d+B,L=0,E;if(j.bbox.ic){L=j.bbox.ic}if(',9,']&&(',9,'].type==="','mi"||',9,28,'mo")){if(',9,'].data.join("").length===1&&j.bbox.scale===1&&!',9,'].Get("largeop")){w=n=0}}var G','=this.getValues("','subscriptshift","','superscriptshift','");','G.subscriptshift','=(',41,'===""?0:b.length2em(',41,'));G.',39,'=(G.',39,'===""?0:b.length2em(G.',39,'));var m=0;if(o){m=','o.bbox.w','+L}else{if(i){m=i.bbox.w-L}}if(m<0){m=0}b.placeBox(j,m,0);if(!e&&!i){n','=Math.max(','n,b.TeX.','sub1*M,',41,');if(l){n',55,'n,l.bbox.h-(4/5)*K)}if(o){n',55,'n,o.bbox.h-(4/5)*K',')}if(l){b.placeBox(l,m+j.bbox.w+z-L,-n)}if(o){b.placeBox(o,','0,-n)}}else{if(!l&&!o){f',37,'displaystyle','","texprimestyle");E=b.TeX[(f.',67,'?"sup1":(f.texprimestyle?"sup3":"sup2"))];w',55,'w,E*M,G.',39,');if(e){w',55,'w,e.bbox.d+(1/4)*K)}if(i){w',55,'w,i.bbox.d+(1/4)*K)}','if(e){b.placeBox(e,m+j.bbox.w+z,w)}if(i){b.placeBox(i,','0,w)}}else{n',55,56,'sub2*M);var x=b.TeX.rule_thickness*M;var I=(l||o).bbox.h,J=(e||i).bbox.d;if(o){I',55,'I,o.bbox.h)}if(i){J',55,'J,i.bbox.d)}if((w-J)-(I-n)<3*x){n=3*x-w+J+I;C=(4/5)*K-(w-J);if(C>0){w+=C;n-=C}}w',55,'w,G.',39,');n',55,'n,',41,');',79,'m+L-i.bbox.w,w',64,'m-',53,',-n)}}}this.HTMLhandleSpace(H);this.HTMLhandleColor(H);return H},',19,':',1,'p,q){var o,d,e=[];var n=1,g=this.data.length,f=0;for(var h=0;h<4;h+=2){while(n<g&&',21,'n].type!=="','mprescripts"){for(var l=h;l<h+2;l++){if(',21,'n]&&',21,107,'none"){if(!e[l]){e[l]=b.createBox(p);e[l].bbox=this.HTMLemptyBBox({});if(f){b.createBlank(e[l],f);','e[l].bbox.','w=',114,'rw=f}}',21,'n].toHTML(e[l]);this.HTMLcombineBBoxes(',21,'n],e[l].bbox)}n++}d=e[h];o=e[h+1];if(d&&o){if(d.bbox.w<','o.bbox.w){b.createBlank(','d,',53,'-d.bbox.w);d.bbox.w=',53,';d.bbox.rw',55,'d.bbox.w,d.bbox.rw)}else{if(d.bbox.w>',122,'o,d.bbox.w-',53,');',53,'=d.bbox.w;o.bbox.rw',55,53,',o.bbox.rw)}}}if(d){f=d.bbox.w}else{if(o){f=',53,'}}}n++;f=0}for(l=0;l<4;l++){if(e[l]){',114,'w+=q;',114,'rw',55,114,'w,',114,'rw);this.HTMLcleanBBox(e[l].bbox)}}return e},',17,':a.mbase.',17,',',13,151,13,'});MathJax.Hub.Startup.signal.Post("HTML-CSS ',3,' Ready");MathJax.Ajax.loadComplete(b.autoloadDir+"/',3,'.js")})(MathJax.ElementJax.mml,MathJax.OutputJax["HTML-CSS"]);']
]);

