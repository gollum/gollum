/*
 *  ../SourceForge/trunk/mathjax/jax/output/HTML-CSS/config.js
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
  ['MathJax.OutputJax','["HTML-CSS','"]=',0,'({name:"','HTML-CSS",','version:"1.0",directory:',0,'.directory+"/HTML-CSS','",extensionDir:',0,'.extensionDir+"/',5,'autoloadDir:',0,8,'/autoload",fontDir:',0,8,'/fonts",webfontDir:',0,'.fontDir+"/',5,'config:{scale:100,availableFonts:["STIX","TeX"],preferredFont:"TeX",webFont:"TeX",imageFont:"TeX",showMathMenu:true,styles:{".MathJax_Display":{"text-align":"center",margin:"1em 0em"},".MathJax .merror','":{"background-color','":"#FFFF88",color:"#CC0000','",border:"1px solid',' #CC0000",padding:"1px 3px","font-family":"serif","font-style":"normal","font-size":"90%"},".','MathJax_Preview','":{color:"#888888"},"#MathJax_Tooltip',24,'":"InfoBackground",color:"InfoText',26,' black","','box-shadow":"2px 2px 5px #AAAAAA','","-webkit-',34,'","-moz-',34,'",filter:"progid:DXImageTransform.Microsoft.dropshadow(OffX=2, OffY=2, Color=\'gray\', Positive=\'true\')",padding:"3px 4px"}}}});',0,1,'"].Register("jax/mml");(function(b,c){var a;a=b.Insert({','minBrowserVersion',':{Firefox:3,Opera:9.52,MSIE:6,Chrome:0.3,Safari:2,Konqueror:4},','inlineMathDelimiters',':["$","$"],','displayMathDelimiters',':["$$","$$"],','multilineDisplay',':true,','minBrowserTranslate',':function(f){var e=b.getJaxFor(f),l=["[Math]"],k;var h=','document.createElement("','span",{className:"',28,'"});var j=e.root.Get("displaystyle");if(e.inputJax.name==="TeX"){if(j){k=a.',47,';l=[k[0]+e.originalText','+k[1]];if(a.',49,'){l=l[0].split(/\\n/)}}else{k=a.',45,58,'.replace(/^\\s+/,"").replace(/\\s+$/,"")+k[1]]}}for(var g=0,d=l.length;g<d;g++){h.appendChild(document.createTextNode(l[g]));if(g<d-1){h.appendChild(',53,'br"))}}f.parentNode.insertBefore(h,f)}},(b.config',1,'"]||{}));if(b.Browser.version!=="0.0"&&!b.Browser.versionAtLeast(a.',43,'[b.Browser]||0)){c.Translate=a.',51,';MathJax.Hub.Config({showProcessingMessages:false});MathJax.Message.Set("Your browser does not support MathJax",null,4000);b.Startup.signal.Post("MathJax not supported")}})(MathJax.Hub,',0,1,'"]);',0,1,'"].loadComplete("config.js");']
]);

