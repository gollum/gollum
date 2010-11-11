/*
 *  ../SourceForge/trunk/mathjax/extensions/TeX/newcommand.js
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
  ['MathJax.Hub.','Register.StartupHook("TeX Jax Ready",function(){var b="1.0";var c=MathJax.InputJax.TeX;var a=c.Definitions;',0,'Insert(a,{macros:{','newcommand',':"','NewCommand','",renewcommand:"',6,'",newenvironment:"','NewEnvironment','",def:"MacroDef"}});c.Parse.Augment({',6,':function(','d){var e=this.','trimSpaces(','this.GetArgument','(d)),g','=this.trimSpaces(this.GetBrackets(','d)),f=',16,'(d);if(g===""){g=null}if(e.charAt(0)==="\\\\"){e=e.substr(1)}if(!e.match(/^(.|[a-z]+)$/i)){','c.Error("','Illegal',' control sequence',' name for "+d)}if(g!=null&&!g','.match(/^[0-9]+$/)){c.Error("Illegal number of parameters specified in "+','d)}','a.macros[e]=["Macro",f,g',']},',10,13,'e){var f=this.trimSpaces(',16,'(e)),h',18,'e)),g=',16,'(e),d=',16,'(e);if(h===""){h=null}if(h!=null&&!h',26,'e)}','a.environment[','f',']=["BeginEnv","EndEnv','",g,d,h]},MacroDef',13,14,'GetCSname','(d),g=this.','GetTemplate','(d,"\\\\"+e),f=',16,'(d);if(!(g instanceof Array)){',28,']}else{a.macros[e]=["','MacroWithTemplate','",f,g[0],g[1]]}},',49,13,'e){var f=','this.GetNext();','if(f!=="\\\\"){c.Error("\\\\ must be followed by a',24,'")}','var d=this.','trimSpaces(',16,'(e));return d.substr(1)},',51,13,'f,e){var j,g=[],h=0;j=',62,66,'i',';while(this.i<this.string.length){','j=',62,'if(j==="#"){','if(d!==this.i){g[h]=this.string.substr(d,this.i-d)}','j=','this.string.','charAt(++this.i);if(!j.match(/^[1-9]$/)){',22,'Illegal use of # in template for "+e)}if(parseInt(j)!=++h){',22,'Parameters for "+e+" must be numbered sequentially")}d=this.i+1}else{if(j==="{"){',80,'if(g.length>0){return[h,g]}else{return h}}}this.i++}',22,'Missing replacement string for definition of "+f)},',57,13,'e,h,j,g){if(j){var d=[];',62,'if(g[0]&&!this.','MatchParam','(g[0])){',22,'Use of "+e+" doesn\'t match its definition")}','for(var f=0;f<','j;f++){d.push(this.','GetParameter','(e,g[f+1]))}h','=this.SubstituteArgs(','d,h)}','this.string=this.AddArgs(','h',',this.string.slice(this.i));this.i=0','},BeginEnv',13,'g,j,d,h){if(h){var e=[];',101,'h;f++){e.push(',16,'("\\\\begin{"+name+"}"))}j',105,'e,j);d',105,'e,d)}g.edef=d;',107,'j',109,';return ','g},EndEnv',13,'d,e){',107,'d.edef',109,124,'e},',103,13,'e,h){if(h==null){return ',16,'(e)}var g=this.i,d=0,f=0',76,'if(',82,'charAt(this.i)==="{"){if(this.i===g){f=1}',16,'(e);d=this.i-g}else{if(this.',97,'(h)){if(f){g++;d-=2}return ',82,'substr(g,d)}else{this.i++;d++;f=0}}}',22,'Runaway argument for "+e+"?")},',97,13,'d){if(',82,'substr(this.i,d.length)!==d){return 0}this.i+=d.length',124,'1}});c.Environment=function(d){',43,'d',45,'"].concat([].slice.call(arguments,1))};',0,'Startup.signal.Post("TeX ',4,' Ready")});MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/',4,'.js");']
]);

