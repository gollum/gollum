/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/boldsymbol.js
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
  ['MathJax.Hub.Register.StartupHook("','TeX',' Jax Ready",function(){var ','c="1.0";var a=','MathJax.','ElementJax.mml;var e=',4,'InputJax.TeX;var b=e.Definitions;var d={};d[','a.VARIANT.','NORMAL]=',8,'BOLD;d[',8,'ITALIC]=',8,'BOLDITALIC;d[',8,'FRAKTUR]=',8,'BOLDFRAKTUR;d[',8,'SCRIPT]=',8,'BOLDSCRIPT;d[',8,'SANSSERIF]=',8,'BOLDSANSSERIF;d','["-tex-caligraphic','"]="-tex-','caligraphic-bold";d','["-tex-oldstyle',29,'oldstyle-bold";b.macros.boldsymbol="Boldsymbol";e.Parse.Augment({mmlToken:function(g){if(','this.stack.env.boldsymbol','){var f=','g.Get("','mathvariant','");if(f==null){g.',37,'=',8,'BOLD}else{g.',37,'=(d[f]||f)}}return g},Boldsymbol:function(i',35,34,',g=','this.stack.env.font',';',34,'=true;',48,'=null;var h=this.ParseArg(i);',48,'=g;',34,'=f;this.Push(h)}})});',0,'HTML-CSS',2,'a=',4,'OutputJax["',59,'"];var c=a.FONTDATA.FONTS;var b=a.FONTDATA.VARIANT;','if(a.fontInUse==="','TeX"){c["MathJax_Caligraphic-bold"]="Caligraphic/Bold/Main.js";b',28,'-bold"]={fonts:["MathJax_Caligraphic-bold","MathJax_Main-bold","MathJax_Main","MathJax_Math","MathJax_Size1','"],offsetA:65,variantA:"','bold-italic','"};b',31,69,'"]};if(','a.msieCheckGreek','&&a.Font.testFont({family:"','MathJax_Greek','",weight:"bold",style:"italic",testString:',76,'})){b["',71,'"].offsetG=913;b["',71,'"].variantG="-','Greek-Bold-Italic','";b["-',86,'"]={fonts:["',78,'-',71,'"]};c["',78,'-',71,'"]="Greek/BoldItalic/Main.js"}if(','MathJax.Hub.Browser.','isChrome&&!',98,'versionAtLeast("5.0")){b',28,'-bold"].remap={84:[58096,"-WinChrome"]}}}else{',66,'STIX"){b',28,'-bold"]={fonts:["STIXGeneral-bold','-italic','","STIXNonUnicode','-',71,109,'","STIXGeneral","STIXSizeOneSym"],','offsetA:57927,noLowerCase:1};b',31,107,109,'-bold',113,'offsetN:57955,remap:{57956:57959,57957:57963,57958:57967,57959:57971,57960:57975,57961:57979,57962:57983,57963:57987,57964:57991}}}}',4,'Hub.Startup.signal.Post("TeX boldsymbol Ready")});',4,'Ajax.loadComplete("[MathJax]/extensions/TeX/boldsymbol.js");']
]);

