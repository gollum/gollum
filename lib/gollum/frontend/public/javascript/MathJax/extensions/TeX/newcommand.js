/*************************************************************
 *
 *  MathJax/extensions/TeX/newcommand.js
 *  
 *  Implements the \newcommand, \newenvironment and \def
 *  macros, and is loaded automatically when needed.
 *
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2009 Design Science, Inc.
 * 
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 */

MathJax.Hub.Register.StartupHook("TeX Jax Ready",function () {
  var TEX = MathJax.InputJax.TeX;
  var TEXDEF = TEX.Definitions;
  
  MathJax.Hub.Insert(TEXDEF,{
    macros: {
      newcommand:     'NewCommand',
      newenvironment: 'NewEnvironment',
      def:            'MacroDef'
    }
  })

  TEX.Parse.Augment({

    /*
     *  Implement \newcommand{\name}[n]{...}
     */
    NewCommand: function (name) {
      var cs = this.trimSpaces(this.GetArgument(name)),
          n  = this.trimSpaces(this.GetBrackets(name)),
          def = this.GetArgument(name);
      if (n === '') {n = null}
      if (cs.charAt(0) === "\\") {cs = cs.substr(1)}
      if (!cs.match(/^(.|[a-z]+)$/i)) {TEX.Error("Illegal control sequence name for "+name)}
      if (n != null && !n.match(/^[0-9]+$/)) {TEX.Error("Illegal number of parameters specified in "+name)}
      TEXDEF.macros[cs] = ['Macro',def,n];
    },
    
    /*
     *  Implement \newenvironment{name}[n]{begincmd}{endcmd}
     */
    NewEnvironment: function (name) {
      var env  = this.trimSpaces(this.GetArgument(name)),
          n    = this.trimSpaces(this.GetBrackets(name)),
          bdef = this.GetArgument(name),
          edef = this.GetArgument(name);
      if (n === '') {n = null}
      if (n != null && !n.match(/^[0-9]+$/)) {TEX.Error("Illegal number of parameters specified in "+name)}
      TEXDEF.environment[env] = ['BeginEnv','EndEnv',bdef,edef,n];
    },
    
    /*
     *  Implement \def command
     */
    MacroDef: function (name) {
      var cs     = this.GetCSname(name),
          params = this.GetTemplate(name,"\\"+cs),
          def    = this.GetArgument(name);
      if (!(params instanceof Array)) {TEXDEF.macros[cs] = ['Macro',def,params]}
        else {TEXDEF.macros[cs] = ['MacroWithTemplate',def,params[0],params[1]]}
    },
    
    /*
     *  Get a CS name or give an error
     */
    GetCSname: function (cmd) {
      var c = this.GetNext();
      if (c !== "\\") {TEX.Error("\\ must be followed by a control sequence")}
      var cs = this.trimSpaces(this.GetArgument(cmd));
      return cs.substr(1);
    },
    
    /*
     *  Get a \def parameter template
     */
    GetTemplate: function (cmd,cs) {
      var c, params = [], n = 0;
      c = this.GetNext(); var i = this.i;
      while (this.i < this.string.length) {
        c = this.GetNext();
        if (c === '#') {
          if (i !== this.i) {params[n] = this.string.substr(i,this.i-i)}
          c = this.string.charAt(++this.i);
          if (!c.match(/^[1-9]$/)) {TEX.Error("Illegal use of # in template for "+cs)}
          if (parseInt(c) != ++n) {TEX.Error("Parameters for "+cs+" must be numbered sequentially")}
          i = this.i+1;
        } else if (c === '{') {
          if (i !== this.i) {params[n] = this.string.substr(i,this.i-i)}
          if (params.length > 0) {return [n,params]} else {return n}
        }
        this.i++;
      }
      TEX.Error("Missing replacement string for definition of "+cmd);
    },
    
    /*
     *  Process a macro with a parameter template
     */
    MacroWithTemplate: function (name,text,n,params) {
      if (n) {
        var args = [], c = this.GetNext();
        if (params[0] && !this.MatchParam(params[0]))
          {TEX.Error("Use of "+name+" doesn't match its definition")}
        for (var i = 0; i < n; i++) {args.push(this.GetParameter(name,params[i+1]))}
        text = this.SubstituteArgs(args,text);
      }
      this.string = this.AddArgs(text,this.string.slice(this.i));
      this.i = 0;
    },
    
    /*
     *  Process a user-defined environment
     */
    BeginEnv: function (begin,bdef,edef,n) {
      if (n) {
        var args = [];
        for (var i = 0; i < n; i++) {args.push(this.GetArgument("\\begin{"+name+"}"))}
        bdef = this.SubstituteArgs(args,bdef);
        edef = this.SubstituteArgs(args,edef);
      }
      begin.edef = edef;
      this.string = this.AddArgs(bdef,this.string.slice(this.i)); this.i = 0;
      return begin;
    },
    EndEnv: function (begin,row) {
      this.string = this.AddArgs(begin.edef,this.string.slice(this.i)); this.i = 0
      return row;
    },
    
    /*
     *  Find a single parameter delimited by a trailing template
     */
    GetParameter: function (name,param) {
      if (param == null) {return this.GetArgument(name)}
      var i = this.i, j = 0, hasBraces = 0;
      while (this.i < this.string.length) {
        if (this.string.charAt(this.i) === '{') {
          if (this.i === i) {hasBraces = 1}
          this.GetArgument(name); j = this.i - i;
        } else if (this.MatchParam(param)) {
          if (hasBraces) {i++; j -= 2}
          return this.string.substr(i,j);
        } else {
          this.i++; j++; hasBraces = 0;
        }
      }
      TEX.Error("Runaway argument for "+name+"?");
    },
    
    /*
     *  Check if a template is at the current location.
     *  (The match must be exact, with no spacing differences.  TeX is
     *   a little more forgiving than this about spaces after macro names)
     */
    MatchParam: function (param) {
      if (this.string.substr(this.i,param.length) !== param) {return 0}
      this.i += param.length;
      return 1;
    }
    
  });
  
  TEX.Environment = function (name) {
    TEXDEF.environment[name] = ['BeginEnv','EndEnv'].concat([].slice.call(arguments,1));
  }

  MathJax.Hub.Startup.signal.Post("TeX newcommand Ready");

});

MathJax.Ajax.loadComplete("[MathJax]/extensions/TeX/newcommand.js");
