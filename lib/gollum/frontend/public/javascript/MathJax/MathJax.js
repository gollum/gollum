/*************************************************************
 *
 *  MathJax.js
 *  
 *  The main support code for the MathJax Hub, including the
 *  Ajax, CallBack, Messaging, and Object-Oriented Programming
 *  libraries, as well as the base Jax classes, and startup
 *  processing code.
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

if (document.getElementById && document.childNodes && document.createElement) {

if (!window.MathJax) {window.MathJax= {}}
MathJax.version = "0.9.8";

/**********************************************************/

(function (BASENAME) {
  var BASE = window[BASENAME];
  if (!BASE) {BASE = window[BASENAME] = {}}

  var PROTO = [];  // a static object used to indicate when a prototype is being created
  var OBJECT = function (def) {
    var obj = def.constructor; if (!obj) {obj = new Function("")}
    for (var id in def) {if (id !== 'constructor' && def.hasOwnProperty(id)) {obj[id] = def[id]}}
    return obj;
  };
  var CONSTRUCTOR = function () {
    return new Function ("return arguments.callee.Init.call(this,arguments)");
  };
  //
  //  Test for Safari 2.x bug (can't replace prototype for result of new Function()).
  //  (We don't use this version for everyone since it is a closure and we don't need that).
  //
  var BUGTEST = CONSTRUCTOR(); BUGTEST.prototype = {bug_test: 1};
  if (!BUGTEST.prototype.bug_test) {
    CONSTRUCTOR = function () {
      return function () {return arguments.callee.Init.call(this,arguments)};
    };
  };

  BASE.Object = OBJECT({
    constructor: CONSTRUCTOR(),
    
    Subclass: function (def,classdef) {
      var obj = CONSTRUCTOR();
      obj.SUPER = this; obj.Init = this.Init;
      obj.Subclass = this.Subclass; obj.Augment = this.Augment;
      obj.protoFunction = this.protoFunction;
      obj.can = this.can; obj.has = this.has; obj.isa = this.isa;
      obj.prototype = new this(PROTO);
      obj.prototype.constructor = obj;  // the real constructor
      obj.Augment(def,classdef);
      return obj;
    },
  
    Init: function (args) {
      var obj = this;
      if (args.length !== 1 || args[0] !== PROTO) {
        if (!(obj instanceof args.callee)) {obj = new args.callee(PROTO)}
        obj.Init.apply(obj,args);
      }
      return obj;
    },
    
    Augment: function (def,classdef) {
      var id;
      if (def != null) {
        for (id in def) {if (def.hasOwnProperty(id)) {this.protoFunction(id,def[id])}}
        // MSIE doesn't list toString even if it is not native so handle it separately
        if (def.toString !== this.prototype.toString && def.toString !== {}.toString)
          {this.protoFunction('toString',def.toString)}
      }
      if (classdef != null) {
        for (id in classdef) {if (classdef.hasOwnProperty(id)) {this[id] = classdef[id]}}
      }
    },
  
    protoFunction: function (id,def) {
      this.prototype[id] = def;
      if (def instanceof Function) {def.SUPER = this.SUPER.prototype}
    },
  
    prototype: {
      Init: function () {},
      SUPER: function (fn) {return fn.callee.SUPER},
      can: function (method) {return typeof(this[method]) === "function"},
      has: function (property) {return typeof(this[property]) !== "undefined"},
      isa: function (obj) {return (obj instanceof Object) && (this instanceof obj)}
    },
  
    can: function (method)   {return this.prototype.can.call(this,method)},
    has: function (property) {return this.prototype.has.call(this,property)},
    isa: function (obj) {
      var constructor = this;
      while (constructor) {
        if (constructor === obj) {return true} else {constructor = constructor.SUPER}
      }
      return false;
    },


    SimpleSUPER: OBJECT({
      constructor: function (def) {return this.SimpleSUPER.define(def)},

      define: function (src) {
	var dst = {};
	if (src != null) {
          for (var id in def) {if (def.hasOwnProperty(id)) {this.protoFunction(id,def[id])}}
	  // MSIE doesn't list toString even if it is not native so handle it separately
          if (def.toString !== this.prototype.toString && def.toString !== {}.toString)
            {this.protoFunction('toString',def.toString)}
	}
	return dst;
      },

      wrap: function (id,f) {
	if (typeof(f) === 'function' && f.toString().match(/\.\s*SUPER\s*\(/)) {
	  var fn = new Function(this.wrapper);
	  fn.label = id; fn.original = f; f = fn;
	  fn.toString = this.stringify;
	}
	return f;
      },

      wrapper: function () {
	var fn = arguments.callee;
	this.SUPER = fn.SUPER[fn.label];
	try {var result = fn.original.apply(this,arguments)}
	  catch (err) {delete this.SUPER; throw err}
	delete this.SUPER;
	return result;
      }.toString().replace(/^\s*function \(\)\s*\{\s*/i,"").replace(/\s*\}\s*$/i,""),

      toString: function () {
	return this.original.toString.apply(this.original,arguments);
      }
    })
  });

})("MathJax");

/**********************************************************/

/*
 *  Create a callback function from various forms of data:
 *  
 *     MathJax.CallBack(fn)    -- callback to a function
 *
 *     MathJax.CallBack([fn])  -- callback to function
 *     MathJax.CallBack([fn,data...])
 *                             -- callback to function with given data as arguments
 *     MathJax.CallBack([object,fn])
 *                             -- call fn with object as "this"
 *     MathJax.CallBack([object,fn,data...])
 *                             -- call fn with object as "this" and data as arguments
 *     MathJax.CallBack(["method",object])
 *                             -- call method of object wth object as "this"
 *     MathJax.CallBack(["method",object,data...])
 *                             -- as above, but with data as arguments to method
 *
 *     MathJax.CallBack({hook: fn, data: [...], object: this})
 *                             -- give function, data, and object to act as "this" explicitly
 *
 *     MathJax.CallBack("code")  -- callback that compiles and executes a string
 *
 *     MathJax.CallBack([...],i)
 *                             -- use slice of array starting at i and interpret
 *                                result as above.  (Used for passing "arguments" array
 *                                and trimming initial arguments, if any.)
 */

/*
 *    MathJax.CallBack.After([...],cb1,cb2,...)
 *                             -- make a callback that isn't called until all the other
 *                                ones are called first.  I.e., wait for a union of
 *                                callbacks to occur before making the given callback.
 */

/*
 *  MathJax.CallBack.Queue([callback,...])
 *                             -- make a synchronized queue of commands that process
 *                                sequentially, waiting for those that return uncalled
 *                                callbacks.
 */

/*
 *  MathJax.CallBack.Signal(name)
 *                             -- finds or creates a names signal, to which listeners
 *                                can be attached and are signaled by messages posted
 *                                to the signal.  Responses can be asynchronous.
 */

(function (BASENAME) {
  var BASE = window[BASENAME];
  if (!BASE) {BASE = window[BASENAME] = {}}
  //
  //  Create a callback from an associative array
  //
  var CALLBACK = function (data) {
    var cb = new Function("return arguments.callee.execute.apply(arguments.callee,arguments)");
    for (var id in CALLBACK.prototype) {
      if (CALLBACK.prototype.hasOwnProperty(id)) {
        if (typeof(data[id]) !== 'undefined') {cb[id] = data[id]}
                                         else {cb[id] = CALLBACK.prototype[id]}
      }
    }
    cb.toString = CALLBACK.prototype.toString;
    return cb;
  };
  CALLBACK.prototype = {
    isCallback: true,
    hook: function () {},
    data: [],
    object: window,
    execute: function () {
      if (!this.called || this.autoReset) {
        this.called = !this.autoReset;
        return this.hook.apply(this.object,this.data.concat([].slice.call(arguments,0)));
      }
    },
    reset: function () {delete this.called},
    toString: function () {return this.hook.toString.apply(this.hook,arguments)}
  };
  var ISCALLBACK = function (f) {
    return (f instanceof Function && f.isCallback);
  }
  //
  //  Evaluate a string in global context
  //
  var EVAL = function (code) {return eval.call(window,code)}
  EVAL("var __TeSt_VaR__ = 1"); // check if it works in global context
  if (window.__TeSt_VaR__) {delete window.__TeSt_VaR__} else {
    if (window.execScript) {
      // IE
      EVAL = function (code) {
        BASE.__code = code;
        code = "try {"+BASENAME+".__result = eval("+BASENAME+".__code)} catch(err) {"+BASENAME+".__result = err}";
        window.execScript(code);
        var result = BASE.__result; delete BASE.__result; delete BASE.__code;
        if (result instanceof Error) {throw result}
        return result;
      }
    } else {
      // Safari2
      EVAL = function (code) {
        BASE.__code = code;
        code = "try {"+BASENAME+".__result = eval("+BASENAME+".__code)} catch(err) {"+BASENAME+".__result = err}";
        var head = (document.getElementsByTagName("head"))[0]; if (!head) {head = document.body}
        var script = document.createElement("script");
        script.appendChild(document.createTextNode(code));
        head.appendChild(script); head.removeChild(script);
        var result = BASE.__result; delete BASE.__result; delete BASE.__code;
        if (result instanceof Error) {throw result}
        return result;
      }
    }
  }
  //
  //  Create a callback from various types of data
  //
  var USING = function (args,i) {
    if (arguments.length > 1) {
      if (arguments.length === 2 && !(arguments[0] instanceof Function) &&
          arguments[0] instanceof Object && typeof arguments[1] === 'number')
            {args = [].slice.call(args,i)}
      else {args = [].slice.call(arguments,0)}
    }
    if (args instanceof Array && args.length === 1) {args = args[0]}
    if (args instanceof Function) {
      if (args.execute === CALLBACK.prototype.execute) {return args}
      return CALLBACK({hook: args});
    } else if (args instanceof Array) {
      if (typeof(args[0]) === 'string' && args[1] instanceof Object &&
                 args[1][args[0]] instanceof Function) {
        return CALLBACK({hook: args[1][args[0]], object: args[1], data: args.slice(2)});
      } else if (args[0] instanceof Function) {
        return CALLBACK({hook: args[0], data: args.slice(1)});
      } else if (args[1] instanceof Function) {
        return CALLBACK({hook: args[1], object: args[0], data: args.slice(2)});
      }
    } else if (typeof(args) === 'string') {
      return CALLBACK({hook: EVAL, data: [args]});
    } else if (args instanceof Object) {
      return CALLBACK(args);
    } else if (typeof(args) === 'undefined') {
      return CALLBACK({});
    }
    throw Error("Can't make callback from given data");
  };
  
  //
  //  Wait for a given time to elapse and then perform the callback
  //
  var DELAY = function (time,callback) {
    callback = USING(callback);
    callback.timeout = setTimeout(callback,time);
    return callback;
  };

  //
  //  Callback used by AFTER, QUEUE, and SIGNAL to check if calls have completed
  //
  var WAITFOR = function (callback,signal) {
    callback = USING(callback);
    if (!callback.called) {WAITSIGNAL(callback,signal); signal.pending++}
  };
  var WAITEXECUTE = function () {
    var signals = this.signal; delete this.signal;
    this.execute = this.oldExecute; delete this.oldExecute;
    var result = this.execute.apply(this,arguments);
    if (ISCALLBACK(result) && !result.called) {WAITSIGNAL(result,signals)} else {
      for (var i = 0, m = signals.length; i < m; i++) {
        signals[i].pending--;
        if (signals[i].pending <= 0) {var result = signals[i].call()}
      }
    }
  };
  var WAITSIGNAL = function (callback,signals) {
    if (!(signals instanceof Array)) {signals = [signals]}
    if (!callback.signal) {
      callback.oldExecute = callback.execute;
      callback.execute = WAITEXECUTE;
      callback.signal = signals;
    } else if (signals.length === 1) {callback.signal.push(signals[0])}
      else {callback.signal = callback.signal.concat(signals)}
  };

  //
  //  Create a callback that is called when a collection of other callbacks have
  //  all been executed.  If the callback gets calledimmediately (i.e., the
  //  others are all already called), check if it returns another callback
  //  and return that instead.
  //
  var AFTER = function (callback) {
    callback = USING(callback);
    callback.pending = 0;
    for (var i = 1, m = arguments.length; i < m; i++)
      {if (arguments[i]) {WAITFOR(arguments[i],callback)}}
    if (callback.pending === 0) {
      var result = callback();
      if (ISCALLBACK(result)) {callback = result}
    }
    return callback;
  };

  //
  //  Run an array of callbacks passing them the given data.
  //  If any return callbacks, return a callback that will be 
  //  executed when they all have completed.
  //
  var HOOKS = function (hooks,data,reset) {
    if (!hooks) {return null}
    if (!(hooks instanceof Array)) {hooks = [hooks]}
    if (!(data instanceof Array))  {data = (data == null ? [] : [data])}
    var callbacks = [{}];
    for (var i = 0, m = hooks.length; i < m; i++) {
      if (reset) {hooks[i].reset()}
      var result = hooks[i].apply(window,data);
      if (ISCALLBACK(result) && !result.called) {callbacks.push(result)}
    }
    if (callbacks.length === 1) {return null}
    if (callbacks.length === 2) {return callbacks[1]}
    return AFTER.apply({},callbacks);
  };
  
  //
  //  Command queue that performs commands in order, waiting when
  //  necessary for commands to complete asynchronousely
  //
  var QUEUE = BASE.Object.Subclass({
    //
    //  Create the queue and push any commands that are specified
    //
    Init: function () {
      this.pending = 0; this.running = 0;
      this.queue = [];
      this.Push.apply(this,arguments);
    },
    //
    //  Add commands to the queue and run them. Adding a callback object
    //  (rather than a callback specification) queues a wait for that callback.
    //  Return the final callback for synchronization purposes.
    //
    Push: function () {
      var callback;
      for (var i = 0, m = arguments.length; i < m; i++) {
        callback = USING(arguments[i]);
        if (callback === arguments[i] && !callback.called)
          {callback = USING(["wait",this,callback])}
        this.queue.push(callback);
      }
      if (!this.running && !this.pending) {this.Process()}
      return callback;
    },
    //
    //  Process the command queue if we aren't waiting on another command
    //
    Process: function (queue) {
      while (!this.running && !this.pending && this.queue.length) {
        var callback = this.queue[0];
        queue = this.queue.slice(1); this.queue = [];
        this.Suspend(); var result = callback(); this.Resume();
        if (queue.length) {this.queue = queue.concat(this.queue)}
        if (ISCALLBACK(result) && !result.called) {WAITFOR(result,this)}
      }
    },
    //
    //  Suspend/Resume command processing on this queue
    //
    Suspend: function () {this.running++},
    Resume: function () {if (this.running) {this.running--}},
    //
    //  Used by WAITFOR to restart the queue when an action completes
    //
    call: function () {this.Process.apply(this,arguments)},
    wait: function (callback) {return callback}
  });
  
  //
  //  Create a named signal that listeners can attach to, to be signaled by
  //  postings made to the signal.  Posts are queued if they occur while one
  //  is already in process.
  //
  var SIGNAL = QUEUE.Subclass({
    Init: function (name) {
      QUEUE.prototype.Init.call(this);
      this.name = name;
      this.posted = [];     // the messages posted so far
      this.listeners = [];  // those with interest in this signal
    },
    //
    // Post a message to the signal listeners, with callback for when complete
    //
    Post: function (message,callback,forget) {
      callback = USING(callback);
      if (this.posting || this.pending) {
        this.Push(["Post",this,message,callback,forget]);
      } else {
        this.callback = callback; callback.reset();
        if (!forget) {this.posted.push(message)}
        this.Suspend(); this.posting = 1;
        for (var i = 0, m = this.listeners.length; i < m; i++) {
          this.listeners[i].reset();
          var result = (this.listeners[i])(message);
          if (ISCALLBACK(result) && !result.called) {WAITFOR(result,this)}
        }
        this.Resume(); delete this.posting;
        if (!this.pending) {this.call()}
      }
      return callback;
    },
    //
    //  Clear the post history (so new listeners won't get old messages)
    //
    Clear: function (callback) {
      callback = USING(callback);
      if (this.posting || this.pending) {
        callback = this.Push(["Clear",this,callback]);
      } else {
        this.posted = [];
        callback();
      }
      return callback;
    },
    //
    //  Call the callback (all replies are in) and process the command queue
    //
    call: function () {this.callback(this); this.Process()},
    
    //
    //  A listener calls this to register intrest in the signal (so it will be called
    //  when posts occur).  If ignorePast is 1, it will not be sent the post history.
    //
    Interest: function (callback,ignorePast) {
      callback = USING(callback);
      this.listeners[this.listeners.length] = callback;
      if (!ignorePast) {
        for (var i = 0, m = this.posted.length; i < m; i++) {
          callback.reset();
          var result = callback(this.posted[i]);
          if (ISCALLBACK(result) && i === this.posted.length-1) {WAITFOR(result,this)}
        }
      }
      return callback;
    },
    //
    //  A listener calls this to remove itself from a signal
    //
    NoInterest: function (callback) {
      for (var i = 0, m = this.listeners.length; i < m; i++) {
        if (this.listeners[i] === callback) {this.listeners.splice(i,1); return}
      }
    },
    
    //
    //  Hook a callback to a particular message on this signal
    //
    MessageHook: function (msg,callback) {
      callback = USING(callback);
      if (!this.hooks) {this.hooks = {}; this.Interest(["ExecuteHooks",this])}
      if (!this.hooks[msg]) {this.hooks[msg] = []}
      this.hooks[msg].push(callback);
      for (var i = 0, m = this.posted.length; i < m; i++)
        {if (this.posted[i] == msg) {callback.reset(); callback(this.posted[i])}}
      return callback;
    },
    //
    //  Execute the message hooks for the given message
    //
    ExecuteHooks: function (msg,more) {
      var type = ((msg instanceof Array) ? msg[0] : msg);
      return HOOKS(this.hooks[type],[msg],true);
    }
    
  },{
    signals: {},  // the named signals
    find: function (name) {
      if (!SIGNAL.signals[name]) {SIGNAL.signals[name] = new SIGNAL(name)}
      return SIGNAL.signals[name];
    }
  });
  
  //
  //  The main entry-points
  //
  BASE.CallBack = USING;
  BASE.CallBack.Delay = DELAY;
  BASE.CallBack.After = AFTER;
  BASE.CallBack.Queue = QUEUE;
  BASE.CallBack.Signal = SIGNAL.find;
  BASE.CallBack.ExecuteHooks = HOOKS;
})("MathJax");

/**********************************************************/

(function (BASENAME) {
  var BASE = window[BASENAME];
  if (!BASE) {BASE = window[BASENAME] = {}}
  
  var isSafari2 = (navigator.vendor === "Apple Computer, Inc." &&
                   typeof navigator.vendorSub === "undefined");
  var sheets = 0; // used by Safari2

  //
  //  Update sheets count and look up the head object
  //  
  var HEAD = function (head) {
    if (document.styleSheets && document.styleSheets.length > sheets)
      {sheets = document.styleSheets.length}
    if (!head) {
      head = (document.getElementsByTagName("head"))[0];
      if (!head) {head = document.body}
    }
    return head;
  };
  
  //
  //  Remove scripts that are completed so they don't clutter up the HEAD.
  //  This runs via setTimeout since IE7 can't remove the script while it is running.
  //
  var SCRIPTS = [];  // stores scripts to be removed after a delay
  var REMOVESCRIPTS = function () {
    for (var i = 0, m = SCRIPTS.length; i < m; i++) {BASE.Ajax.head.removeChild(SCRIPTS[i])}
    SCRIPTS = [];
  };
  
  BASE.Ajax = {
    loaded: {},         // files already loaded
    loading: {},        // files currently in process of loading
    loadHooks: {},      // hooks to call when files are loaded
    timeout: 15*1000,   // timeout for loading of files (15 seconds)
    styleDelay: 1,      // delay to use before styles are available
    config: {root: ""}, // URL of root directory to load from

    STATUS: {
      OK: 1,         // file is loading or did load OK
      ERROR: -1      // file timed out during load
    },
    
    rootPattern: new RegExp("^\\["+BASENAME+"\\]"),
    
    //
    //  Return a complete URL to a file (replacing the root pattern)
    //
    fileURL: function (file) {return file.replace(this.rootPattern,this.config.root)},
    
    //
    //  Load a file if it hasn't been already.
    //  Make sure the file URL is "safe"?
    //
    Require: function (file,callback) {
      callback = BASE.CallBack(callback); var type;
      if (file instanceof Object) {for (var i in file) {}; type = i.toUpperCase(); file = file[i]}
        else {type = file.split(/\./).pop().toUpperCase()}
      file = this.fileURL(file);
      // FIXME: check that URL is OK
      if (this.loaded[file]) {
        callback(this.loaded[file]);
      } else {
        var FILE = {}; FILE[type] = file;
        this.Load(FILE,callback);
      }
      return callback;
    },

    //
    //  Load a file regardless of where it is and whether it has
    //  already been loaded.
    //
    Load: function (file,callback) {
      callback = BASE.CallBack(callback); var type;
      if (file instanceof Object) {for (var i in file) {}; type = i.toUpperCase(); file = file[i]}
        else {type = file.split(/\./).pop().toUpperCase()}
      file = this.fileURL(file);
      if (this.loading[file]) {
        this.loading[file].callbacks.push(callback);
      } else {
        this.head = HEAD(this.head);
        if (this.loader[type]) {this.loader[type].call(this,file,callback)}
         else {throw Error("Can't load files of type "+type)}
      }
      return callback;
    },
    
    //
    //  Register a load hook for a particular file (it will be called when
    //  loadComplete() is called for that file)
    //
    LoadHook: function (file,callback) {
      callback = BASE.CallBack(callback);
      if (file instanceof Object) {for (var i in file) {file = file[i]}}
      file = this.fileURL(file);
      if (this.loaded[file]) {
        callback(this.loaded[file]);
      } else {
        if (!this.loadHooks[file]) {this.loadHooks[file] = []}
        this.loadHooks[file].push(callback);
      }
      return callback;
    },
    
    //
    //  Code used to load the various types of files
    //  (JS for JavaScript, CSS for style sheets)
    //
    loader: {
      //
      //  Create a SCRIPT tag to load the file
      //
      JS: function (file,callback) {
        var script = document.createElement("script");
        var timeout = BASE.CallBack(["loadTimeout",this,file]);
        this.loading[file] = {
          callbacks: [callback],
          message: BASE.Message.File(file),
          timeout: setTimeout(timeout,this.timeout),
          status: this.STATUS.OK,
          script: script
        };
        script.onerror = timeout;  // doesn't work in IE and no apparent substitute
        script.type = "text/javascript";
        script.src = file;
        this.head.appendChild(script);
      },
      //
      //  Create a LINK tag to load the style sheet
      //
      CSS: function (file,callback) {
        var link = document.createElement("link");
        link.rel = "stylesheet"; link.type = "text/css"; link.href = file;
        this.loading[file] = {
          callbacks: [callback],
          message: BASE.Message.File(file),
          status: this.STATUS.OK
        };
        this.head.appendChild(link);
        this.timer.create.call(this,[this.timer.file,file],link);
      }
    },
    
    //
    //  Timing code for checking when style sheets are available.
    //
    timer: {
      //
      //  Create the timing callback and start the timing loop.
      //  We use a delay because some browsers need it to allow the styles
      //  to be processed.
      //
      create: function (callback,node) {
        var check; callback = BASE.CallBack(callback);
        if (node.nodeName === "STYLE" && node.styleSheet &&
            typeof(node.styleSheet.cssText) !== 'undefined') {
          callback(this.STATUS.OK); // MSIE processes style immediately, but doesn't set its styleSheet!
        } else if (window.chrome && typeof(window.sessionStorage) !== "undefined" &&
                   node.nodeName === "STYLE") {
          callback(this.STATUS.OK); // Same for Chrome 5 (beta), Grrr.
        } else if (isSafari2) {
          this.timer.start(this,[this.timer.checkSafari2,sheets++,callback],this.styleDelay);
        } else {
          this.timer.start(this,[this.timer.checkLength,node,callback],this.styleDelay);
        }
        return callback;
      },
      //
      //  Start the timer for the given callback checker
      //
      start: function (AJAX,check,delay) {
        check = BASE.CallBack(check);
        check.execute = this.execute; check.time = this.time;
        check.STATUS = AJAX.STATUS; check.timeout = AJAX.timeout;
        check.delay = check.total = 0;
        setTimeout(check,delay);
      },
      //
      //  Increment the time total, increase the delay
      //  and test if we are past the timeout time.
      //  
      time: function (callback) {
        this.total += this.delay;
        this.delay = Math.floor(this.delay * 1.05 + 5);
        if (this.total >= this.timeout) {callback(this.STATUS.ERROR); return 1}
        return 0;
      },
      //
      //  For JS file loads, call the proper routine according to status
      //
      file: function (file,status) {
        if (status < 0) {BASE.Ajax.loadTimeout(file)} else {BASE.Ajax.loadComplete(file)}
      },
      //
      //  Call the hook with the required data
      //
      execute: function () {this.hook.call(this.object,this,this.data[0],this.data[1])},
      //
      //  Safari2 doesn't set the link's stylesheet, so we need to look in the
      //  document.styleSheets array for the new sheet when it is created
      //
      checkSafari2: function (check,length,callback) {
        if (check.time(callback)) return;
        if (document.styleSheets.length > length &&
            document.styleSheets[length].cssRules &&
            document.styleSheets[length].cssRules.length)
          {callback(check.STATUS.OK)} else {setTimeout(check,check.delay)}
      },
      //
      //  Look for the stylesheets rules and check when they are defined
      //  and no longer of length zero.  (This assumes there actually ARE
      //  some rules in the stylesheet.)
      //  
      checkLength: function (check,node,callback) {
        if (check.time(callback)) return;
        var isStyle = 0; var sheet = (node.sheet || node.styleSheet);
        try {if ((sheet.cssRules||sheet.rules||[]).length > 0) {isStyle = 1}} catch(err) {
          if (err.message.match(/protected variable|restricted URI/)) {isStyle = 1}
          else if (err.message.match(/Security error/)) {
            // Firefox3 gives "Security error" for missing files, so
            //   can't distinguish that from OK files on remote servers.
            //   or OK files in different directory from local files.
            isStyle = 1; // just say it is OK (can't really tell)
          }
        }
        if (isStyle) {
          // Opera 9.6 requires this setTimeout
          setTimeout(BASE.CallBack([callback,check.STATUS.OK]),0);
        } else {
          setTimeout(check,check.delay);
        }
      }
    },

    //
    //  JavaScript code must call this when they are completely initialized
    //  (this allows them to perform asynchronous actions before indicating
    //  that they are complete).
    //
    loadComplete: function (file) {
      file = this.fileURL(file);
      var loading = this.loading[file];
      if (loading) {
        BASE.Message.Clear(loading.message);
        clearTimeout(loading.timeout);
	if (loading.script) {
	  if (SCRIPTS.length === 0) {setTimeout(REMOVESCRIPTS,0)}
	  SCRIPTS.push(loading.script);
	}
        this.loaded[file] = loading.status; delete this.loading[file];
        if (this.loadHooks[file]) {
          BASE.CallBack.Queue(
            [BASE.CallBack.ExecuteHooks,this.loadHooks[file],loading.status],
            [BASE.CallBack.ExecuteHooks,loading.callbacks,loading.status]
          );
        } else {
          BASE.CallBack.ExecuteHooks(loading.callbacks,loading.status);
        }
      }
    },
    
    //
    //  If a file fails to load within the timeout period (or the onerror handler
    //  is called), this routine runs to signal the error condition.
    //  
    loadTimeout: function (file) {
      if (this.loading[file].timeout) {clearTimeout(this.loading[file].timeout)}
      this.loading[file].status = this.STATUS.ERROR;
      this.loadError(file);
      this.loadComplete(file);
    },
    
    //
    //  The default error hook for file load failures
    //
    loadError: function (file) {BASE.Message.Set("File failed to load: "+file,null,2000)},

    //
    //  Defines a style sheet from a hash of style declarations (key:value pairs
    //  where the key is the style selector and the value is a hash of CSS attributes 
    //  and values).
    //
    Styles: function (styles,callback) {
      var styleString = this.StyleString(styles);
      if (styleString === "") {
        callback = BASE.CallBack(callback);
        callback();
      } else {
        var style = document.createElement("style"); style.type = "text/css";
        this.head = HEAD(this.head);
        this.head.appendChild(style);
        if (style.styleSheet && typeof(style.styleSheet.cssText) !== 'undefined') {
          style.styleSheet.cssText = styleString;
        } else {
          style.appendChild(document.createTextNode(styleString));
        }
        callback = this.timer.create.call(this,callback,style);
      }
      return callback;
    },
    
    //
    //  Create a stylesheet string from a style declaration object
    //
    StyleString: function (styles) {
      if (typeof(styles) === 'string') {return styles}
      var string = "", id;
      for (id in styles) {if (styles.hasOwnProperty(id)) {
        if (typeof styles[id] === 'string') {
          string += id + " {"+styles[id]+"}\n";
        } else if (styles[id] instanceof Array) {
          for (var i = 0; i < styles[id].length; i++) {
            var style = {}; style[id] = styles[id][i];
            string += this.StyleString(style);
          }
        } else if (id.substr(0,6) === '@media') {
          string += id + " {"+this.StyleString(styles[id])+"}\n";
        } else if (styles[id] != null) {
          var style = [];
          for (var name in styles[id]) {
            if (styles[id][name] != null)
              {style[style.length] = name + ': ' + styles[id][name]}
          }
          string += id +" {"+style.join('; ')+"}\n";
        }
      }}
      return string;
    }
  };

})("MathJax");

/**********************************************************/

MathJax.Message = {
  log: [{}], current: null,
  textNodeBug: (navigator.vendor === "Apple Computer, Inc." &&
                typeof navigator.vendorSub === "undefined") ||
               (window.hasOwnProperty && window.hasOwnProperty("konqueror")), // Konqueror displays some gibberish with text.nodeValue = "..."
  
  styles: {
    "#MathJax_Message": {
      position: "fixed", left: "1px", bottom: "2px",
      'background-color': "#E6E6E6",  border: "1px solid #959595",
      margin: "0px", padding: "2px 8px",
      'z-index': "102", color: "black", 'font-size': "80%",
      width: "auto", 'white-space': "nowrap"
    },
    
    "#MathJax_MSIE_Frame": {
      position: "absolute",
      top:0, left: 0, width: "0px", 'z-index': 101,
      border: "0px", margin: "0px", padding: "0px"
    }
  },
  
  browsers: {
    MSIE: function (browser) {
      MathJax.Hub.config.styles["#MathJax_Message"].position = "absolute";
      MathJax.Message.quirks = (document.compatMode === "BackCompat");
    },
    Chrome: function (browser) {
      MathJax.Hub.config.styles["#MathJax_Message"].bottom = "1.5em";
      MathJax.Hub.config.styles["#MathJax_Message"].left = "1em";
    }
  },
  
  Init: function() {
    if (!document.body) {return false}
    if (!this.div) {
      var frame = document.body;
      if (MathJax.Hub.Browser.isMSIE) {
        frame = this.frame = this.addDiv(document.body);
        frame.style.position = "absolute";
        frame.style.border = frame.style.margin = frame.style.padding = "0px";
        frame.style.zIndex = "101"; frame.style.height = "0px";
        frame = this.addDiv(frame);
        frame.id = "MathJax_MSIE_Frame";
        window.attachEvent("onscroll",this.MoveFrame);
        window.attachEvent("onresize",this.MoveFrame);
        this.MoveFrame();
      }
      this.div = this.addDiv(frame);
      this.div.id = "MathJax_Message"; this.div.style.display = "none";
      this.text = this.div.appendChild(document.createTextNode(""));
    }
    return true;
  },
  
  addDiv: function (parent) {
    var div = document.createElement("div");
    if (parent.firstChild) {parent.insertBefore(div,parent.firstChild)}
      else {parent.appendChild(div)}
    return div;
  },
  
  MoveFrame: function () {
    var body = (MathJax.Message.quirks ? document.body : document.documentElement);
    var frame = MathJax.Message.frame;
    frame.style.left = body.scrollLeft + 'px';
    frame.style.top = body.scrollTop + 'px';
    frame.style.width = body.clientWidth + 'px';
    frame = frame.firstChild;
    frame.style.height = body.clientHeight + 'px';
  },
  
  Set: function (text,n,clearDelay) {
    if (this.timer) {clearTimeout(this.timer); delete this.timeout}
    if (n == null) {n = this.log.length; this.log[n] = {}}
    this.log[n].text = text;
    if (typeof(this.log[n].next) === "undefined") {
      this.log[n].next = this.current;
      if (this.current != null) {this.log[this.current].prev = n}
      this.current = n;
    }
    if (this.current === n) {
      if (this.Init()) {
        if (this.textNodeBug) {this.div.innerHTML = text} else {this.text.nodeValue = text}
        this.div.style.display = "";
        if (this.status) {window.status = ""; delete this.status}
      } else {
        window.status = text;
        this.status = true;
      }
    }
    if (clearDelay) {setTimeout(MathJax.CallBack(["Clear",this,n]),clearDelay)}
    return n;
  },
  
  Clear: function (n,delay) {
    if (this.log[n].prev != null) {this.log[this.log[n].prev].next = this.log[n].next}
    if (this.log[n].next != null) {this.log[this.log[n].next].prev = this.log[n].prev}
    if (this.current === n) {
      this.current = this.log[n].next;
      if (this.text) {
        if (this.current == null) {
          if (this.timer) {clearTimeout(this.timer)}
          this.timer = setTimeout(MathJax.CallBack(["Remove",this]),(delay||600));
        } else if (this.textNodeBug) {this.div.innerHTML = this.log[this.current].text}
                                else {this.text.nodeValue = this.log[this.current].text}
        if (this.status) {window.status = ""; delete this.status}
      } else if (this.status) {
        window.status = (this.current == null ? "" : this.log[this.current].text);
      }
    }
    delete this.log[n].next; delete this.log[n].prev;
  },
  
  Remove: function () {
    // FIXME:  do a fade out or something else interesting?
    this.text.nodeValue = "";
    this.div.style.display = "none";
  },
  
  File: function (file) {
    var root = MathJax.Ajax.config.root;
    if (file.substr(0,root.length) === root) {file = "[MathJax]"+file.substr(root.length)}
    return this.Set("Loading "+file);
  },
  
  Log: function () {
    var strings = [];
    for (var i = 1, m = this.log.length; i < m; i++) {strings[i] = this.log[i].text}
    return strings.join("\n");
  }

};

/**********************************************************/

MathJax.Hub = {
  config: {
    root: "",
    config: [],      // list of configuration files to load
    styleSheets: [], // list of CSS files to load
    styles: MathJax.Message.styles, // styles to generate in-line
    jax: [],         // list of input and output jax to load
    extensions: [],  // list of extensions to load
    browser: {},     // browser-specific files to load (by browser name)
    preJax: null,    // pattern to remove from before math script tag
    postJax: null,   // pattern to remove from after math script tag
    preRemoveClass: 'MathJax_Preview', // class of objects to remove preceeding math script
    showProcessingMessages: true, // display "Processing math: nn%" messages or not
    delayStartupUntil: "none",    // set to "onload" to delay setup until the onload handler runs
                                  //  or to a CallBack to wait for before continuing with the startup
    skipStartupTypeset: false,    // set to true to skip PreProcess and Process during startup
    
    preProcessors: [], // list of callbacks for preprocessing (initialized by extensions)
    inputJax: {},      // mime-type mapped to input jax (by registration)
    outputJax: {}      // mime-type mapped to output jax list (by registration)
  },
  
  processUpdateTime: 500, // time between screen updates when processing math (milliseconds)

  signal: MathJax.CallBack.Signal("Hub"), // Signal used for Hub events

  Config: function (def) {
    this.Insert(this.config,def);
    if (this.config.Augment) {this.Augment(this.config.Augment)}
  },
  
  Register: {
    PreProcessor: function (callback) {MathJax.Hub.config.preProcessors.push(MathJax.CallBack(callback))},
    BrowserHook: function (browser,callback) {
      var browsers = MathJax.Hub.Startup.browsers;
      if (!browsers[browser]) {browsers[browser] = []}
      if (!(browsers[browser] instanceof Array)) {browsers[browser] = [browsers[browser]]}
      browsers[browser].push(callback);
    },
    MessageHook: function () {return MathJax.Hub.signal.MessageHook.apply(MathJax.Hub.signal,arguments)},
    StartupHook: function () {return MathJax.Hub.Startup.signal.MessageHook.apply(MathJax.Hub.Startup.signal,arguments)},
    LoadHook: function () {return MathJax.Ajax.LoadHook.apply(MathJax.Ajax,arguments)}
  },
  
  getAllJax: function (element) {
    var jax = [], scripts = this.elementScripts(element);
    for (var i = 0, m = scripts.length; i < m; i++) {
      if (scripts[i].MathJax && scripts[i].MathJax.elementJax)
        {jax.push(scripts[i].MathJax.elementJax)}
    }
    return jax;
  },
  
  getJaxByType: function (type,element) {
    var jax = [], scripts = this.elementScripts(element);
    for (var i = 0, m = scripts.length; i < m; i++) {
      if (scripts[i].MathJax && scripts[i].MathJax.elementJax &&
          scripts[i].MathJax.elementJax.mimeType === type)
            {jax.push(scripts[i].MathJax.elementJax)}
    }
    return jax;
  },
  
  getJaxByInputType: function (type,element) {
    var jax = [], scripts = this.elementScripts(element);
    for (var i = 0, m = scripts.length; i < m; i++) {
      if (scripts[i].MathJax && scripts[i].MathJax.elementJax &&
          scripts[i].type && scripts[i].type.replace(/ *;(.|\s)*/,"") === type)
        {jax.push(scripts[i].MathJax.elementJax)}
    }
    return jax;
  },
  
  getJaxFor: function (element) {
    if (typeof(element) === 'string') {element = document.getElementById(element)}
    if (element.MathJax) {return element.MathJax.elementJax}
    // FIXME: also check for results of outputJax
    return null;
  },
  
  isJax: function (element) {
    if (typeof(element) === 'string') {element = document.getElementById(element)}
    if (element.tagName != null && element.tagName.toLowerCase() === 'script') {
      if (element.MathJax) 
        {return (element.MathJax.state === MathJax.ElementJax.STATE.PROCESSED ? 1 : -1)}
      if (element.type && this.config.inputJax[element.type.replace(/ *;(.|\s)*/,"")]) {return -1}
    }
    // FIXME: check for results of outputJax
    return 0;
  },
  
  Typeset: function (element,callback) {
    if (!MathJax.isReady) return null;
    var ec = this.elementCallBack(element,callback);
    return MathJax.CallBack.Queue(
      ["PreProcess",this,ec.element],
      ["Process",this,ec.element]
    ).Push(ec.callback);
  },
  
  PreProcess: function (element,callback) {
    var ec = this.elementCallBack(element,callback);
    return MathJax.CallBack.Queue(
      ["Post",this.signal,"Begin PreProcess"],
      ["ExecuteHooks",MathJax.CallBack,
        (arguments.callee.disabled ? [] : this.config.preProcessors), ec.element, true],
      ["Post",this.signal,"End PreProcess"]
    ).Push(ec.callback);
  },

  Process:   function (element,callback) {return this.takeAction("Process",element,callback)},
  Update:    function (element,callback) {return this.takeAction("Update",element,callback)},
  Reprocess: function (element,callback) {return this.takeAction("Reprocess",element,callback)},
  
  takeAction: function (action,element,callback) {
    var ec = this.elementCallBack(element,callback);
    var scripts = []; // filled in by prepareScripts
    return MathJax.CallBack.Queue(
      ["Clear",this.signal],
      ["Post",this.signal,["Begin "+action,ec.element]],
      ["prepareScripts",this,action,ec.element,scripts],
      ["processScripts",this,scripts],
      ["Post",this.signal,["End "+action,ec.element]]
    ).Push(ec.callback);
  },
  
  scriptAction: {
    Process: function (script) {},
    Update: function (script) {
      var jax = script.MathJax.elementJax;
      if (jax && jax.originalText !== 
            (script.text == ""? script.innerHTML : script.text)) {jax.Remove()}
    },
    Reprocess: function (script) {
      if (script.MathJax.elementJax) {script.MathJax.elementJax.Remove()}
    }
  },
  
  prepareScripts: function (action,element,math) {
    if (arguments.callee.disabled) return;
    var scripts = this.elementScripts(element);
    var STATE = MathJax.ElementJax.STATE;
    for (var i = 0, m = scripts.length; i < m; i++) {
      var script = scripts[i];
      if (script.type && this.config.inputJax[script.type.replace(/ *;(.|\n)*/,"")]) {
        if (script.MathJax && script.MathJax.state === STATE.PROCESSED)
          {this.scriptAction[action](script)}
        if (!script.MathJax) {script.MathJax = {state: STATE.PENDING}}
        if (script.MathJax.state !== STATE.PROCESSED) {math.push(script)}
      }
    }
  },
  
  checkScriptSiblings: function (script) {
    if (script.MathJax && script.MathJax.checked) return;
    var config = this.config;
    var pre = script.previousSibling;
    if (pre && pre.nodeName == "#text") {
      var preJax,postJax;
      var post = script.nextSibling;
      if (post && post.nodeName != "#text") {post = null}
      if (config.preJax)          {preJax = pre.nodeValue.match(config.preJax+"$")}
      if (config.postJax && post) {postJax = post.nodeValue.match("^"+config.postJax)}
      if (preJax && (!config.postJax || postJax)) {
        pre.nodeValue  = pre.nodeValue.replace
          (config.preJax+"$",(preJax.length > 1? preJax[1] : ""));
        pre = null;
      }
      if (postJax && (!config.preJax || preJax)) {
        post.nodeValue = post.nodeValue.replace
          ("^"+config.postJax,(postJax.length > 1? postJax[1] : ""));
      }
      if (pre && !pre.nodeValue.match(/\S/)) {pre = pre.previousSibling}
    }
    if (config.preRemoveClass && pre && pre.className == config.preRemoveClass) {
      try {pre.innerHTML = ""} catch (err) {}
      pre.style.display = "none";
    }
    if (script.MathJax) {script.MathJax.checked = 1}
  },
  
  processScripts: function (scripts,start,n) {
    if (arguments.callee.disabled) {return null}
    var result, STATE = MathJax.ElementJax.STATE;
    var inputJax = this.config.inputJax, outputJax = this.config.outputJax;
    try {
      if (!start) {start = new Date().getTime()}
      var i = 0, script;
      while (i < scripts.length) {
        script = scripts[i]; if (!script) continue;
        var type = script.type.replace(/ *;(.|\s)*/,"");
        if (!script.MathJax || script.MathJax.state === STATE.PROCESSED) continue;
        if (!script.MathJax.elementJax || script.MathJax.state === STATE.UPDATE) {
          this.checkScriptSiblings(script);
          result = inputJax[type].Translate(script);
          if (result instanceof Function) {
            if (result.called) continue; // go back and call Translate() again
            this.RestartAfter(result);
          }
          result.Attach(script,inputJax[type]);
        }
        var jax = script.MathJax.elementJax;
        if (!outputJax[jax.mimeType]) {
          script.MathJax.state = STATE.UPDATE;
          throw Error("No output jax registered for "+jax.mimeType);
        }
        jax.outputJax = outputJax[jax.mimeType][0];
        result = jax.outputJax.Translate(script);
        if (result instanceof Function) {
          script.MathJax.state = STATE.UPDATE;
          if (result.called) continue; // go back and call Translate() again
          this.RestartAfter(result);
        }
        script.MathJax.state = STATE.PROCESSED;
        this.signal.Post(["New Math",jax.inputID]); // FIXME: wait for this?  (i.e., restart if returns uncalled callback)
        i++;
        if (new Date().getTime() - start > this.processUpdateTime && i < scripts.length)
          {start = 0; this.RestartAfter(MathJax.CallBack.Delay(1))}
      }
    } catch (err) {
      if (!err.restart) {throw err}
      if (!n) {n = 0}; var m = Math.floor((n+i)/(n+scripts.length)*100); n += i;
      if (this.config.showProcessingMessages) {MathJax.Message.Set("Processing math: "+m+"%",0)}
      return MathJax.CallBack.After(["processScripts",this,scripts.slice(i),start,n],err.restart);
    }
    if ((n || scripts.length) && this.config.showProcessingMessages) {
      MathJax.Message.Set("Processing Math: 100%",0);
      MathJax.Message.Clear(0);
    }
    return null;
  },
  
  RestartAfter: function (callback) {
    throw this.Insert(Error("restart"),{restart: MathJax.CallBack(callback)});
  },
  
  elementCallBack: function (element,callback) {
    if (callback == null && (element instanceof Array || element instanceof Function))
      {callback = element; element = document.body}
    else if (element == null) {element = document.body}
    else if (typeof(element) === 'string') {element = document.getElementById(element)}
    if (!element) {throw Error("No such element")}
    if (!callback) {callback = {}}
    return {element: element, callback: callback};
  },
  
  elementScripts: function (element) {
    if (typeof(element) === 'string') {element = document.getElementById(element)}
    if (element == null) {element = document.body}
    if (element.tagName != null && element.tagName.toLowerCase() === "script") {return [element]}
    return element.getElementsByTagName("script");
  },
  
  Insert: function (dst,src) {
    for (var id in src) {if (src.hasOwnProperty(id)) {
      // allow for concatenation of arrays?
      if (typeof src[id] === 'object' && !(src[id] instanceof Array) &&
         (typeof dst[id] === 'object' || typeof dst[id] === 'function')) {
        this.Insert(dst[id],src[id]);
      } else {
        dst[id] = src[id];
      }
    }}
    return dst;
  }
};

//
//  Storage area for preprocessors and extensions
//  (should these be classes?)
//
MathJax.PreProcessor = {};
MathJax.Extension = {};

//
//  Hub Startup code
//
MathJax.Hub.Startup = {
  script: "", // the startup script from the SCRIPT call that loads MathJax.js
  queue:   MathJax.CallBack.Queue(),           // Queue used for startup actions
  signal:  MathJax.CallBack.Signal("Startup"), // Signal used for startup events

  //
  //  Load the configuration files
  //
  Config: function () {
    this.queue.Push(["Post",this.signal,"Begin Config"]);
    if (this.script.match(/\S/)) {this.queue.Push(this.script+';1')}
      else {this.queue.Push(["Require",MathJax.Ajax,this.URL("config","MathJax.js")])}
    if (MathJax.userConfig)
      {this.queue.Push(function () {try {MathJax.userConfig()} catch(e) {}})}
    return this.queue.Push(
      [function (config,onload) {
        if (config.delayStartupUntil.isCallback) {return config.delayStartupUntil}
        if (config.delayStartupUntil === "onload") {return onload}
        return function () {};
      }, MathJax.Hub.config, this.onload],
      ["loadArray",this,MathJax.Hub.config.config,"config"],
      ["Post",this.signal,"End Config"]
    );
  },
  //
  //  Setup stylesheets and extra styles
  //
  Styles: function () {
    return this.queue.Push(
      ["Post",this.signal,"Begin Styles"],
      ["loadArray",this,MathJax.Hub.config.styleSheets,"config"],
      ["Styles",MathJax.Ajax,MathJax.Hub.config.styles],
      ["Post",this.signal,"End Styles"]
    );
  },
  //
  //  Load the input and output jax
  //
  Jax: function () {
    return this.queue.Push(
      ["Post",this.signal,"Begin Jax"],
      ["loadArray",this,MathJax.Hub.config.jax,"jax","config.js"],
      ["Post",this.signal,"End Jax"]
    );
  },
  //
  //  Load the extensions
  //
  Extensions: function () {
    return this.queue.Push(
      ["Post",this.signal,"Begin Extensions"],
      ["loadArray",this,MathJax.Hub.config.extensions,"extensions"],
      ["Post",this.signal,"End Extensions"]
    );
  },
  
  //
  //  Setup the onload callback
  //
  onLoad: function (when) {
    var onload = this.onload =
      MathJax.CallBack(function () {MathJax.Hub.Startup.signal.Post("onLoad")});
    if (window.addEventListener) {window.addEventListener("load",onload,false)}
    else if (window.attachEvent) {window.attachEvent("onload",onload)}
    else {window.onload = onload}
    return onload;
  },

  //
  //  Load any browser-specific config files
  //  then call any registered browser hooks
  //
  Browser: function () {
    this.queue.Push(["Post",this.signal,"Begin Browser"]);
    var browser = MathJax.Hub.config.browser[MathJax.Hub.Browser];
    this.queue.Push(["loadArray",this,browser,"config/browsers"]);
    var hooks = this.browsers[MathJax.Hub.Browser];
    if (!(hooks instanceof Array)) {hooks = [hooks]}
    this.queue.Push.apply(this.queue,hooks);
    return this.queue.Push(["Post",this.signal,"End Browser"]);
  },
  
  //
  //  Code to initialize browsers
  //
  browsers: {
    MSIE: function (browser) {},
    Firefox: function (browser) {},
    Safari: function (browser) {},
    Opera: function (browser) {},
    Chrome: function (browser) {}
  },
  
  //
  //  Perform the initial typesetting (or skip if configuration says to)
  //
  Typeset: function (element,callback) {
    if (MathJax.Hub.config.skipStartupTypeset) {return function () {}}
    return this.queue.Push(
      ["Post",this.signal,"Begin Typeset"],
      ["Typeset",MathJax.Hub,element,callback],
      ["Post",this.signal,"End Typeset"]
    );
  },

  //
  //  Create a URL in the MathJax hierarchy
  //
  URL: function (dir,name) {
    if (!name.match(/^([a-z]+:\/\/|\[|\/)/)) {name = "[MathJax]/"+dir+"/"+name}
    return name;
  },

  //
  //  Load an array of files, waiting for all of them
  //  to be loaded before going on
  //
  loadArray: function (files,dir,name) {
    if (files) {
      if (!(files instanceof Array)) {files = [files]}
      if (files.length) {
        var queue = MathJax.CallBack.Queue(), callback = {}, file;
        for (var i = 0, m = files.length; i < m; i++) {
          file = this.URL(dir,files[i]);
          if (name) {file += "/" + name}
          queue.Push(MathJax.Ajax.Require(file,callback));
//          queue.Push(["Require",MathJax.Ajax,file,callback]);
        }
        return queue.Push({}); // wait for everything to finish
      }
    }
    return null;
  }
  
};


/**********************************************************/

(function (BASENAME) {
  var BASE = window[BASENAME];
  var HUB = BASE.Hub, AJAX = BASE.Ajax, CALLBACK = BASE.CallBack;

  var JAX = MathJax.Object.Subclass({
    require: null, // array of files to load before jax.js is complete
    Init: function (def) {this.config = {}; HUB.Insert(this,def)},
    Augment: function (def) {HUB.Insert(this,def)},
    Translate: function (element) {
      this.Translate = this.noTranslate;
      return AJAX.Require(this.directory+"/jax.js");
    },
    noTranslate: function (element) {
      throw Error(this.directory+"/jax.js failed to redefine the Translate() method");
    },
    Register: function (mimetype) {},
    Config: function () {
      HUB.Insert(this.config,(HUB.config[this.name]||{}));
      if (this.config.Augment) {this.Augment(this.config.Augment)}
    },
    Startup: function () {},
    loadComplete: function (file) {
      if (file === "jax.js") {
        var queue = CALLBACK.Queue();
        queue.Push(["Post",HUB.Startup.signal,this.name+" Jax Config"]);
        queue.Push(["Config",this]);
        queue.Push(["Post",HUB.Startup.signal,this.name+" Jax Require"]);
        if (this.require) {
          var require = this.require; if (!(require instanceof Array)) {require = [require]}
          for (var i = 0, m = require.length; i < m; i++) {queue.Push(AJAX.Require(require[i]))}
          queue.Push(["loadArray",MathJax.Hub.Startup,this.config.require,"config"]);
        }
        queue.Push(["Post",HUB.Startup.signal,this.name+" Jax Startup"]);
        queue.Push(["Startup",this]);
        queue.Push(["Post",HUB.Startup.signal,this.name+" Jax Ready"]);
        return queue.Push(["loadComplete",AJAX,this.directory+"/"+file]);
      } else {
        return AJAX.loadComplete(this.directory+"/"+file);
      }
    }
  },{
    name: "unknown",
    version: 1.0,
    directory: "["+BASENAME+"]/jax",
    extensionDir: "["+BASENAME+"]/extensions"
  });

  /***********************************/

  BASE.InputJax = JAX.Subclass({
    Register: function (mimetype) {
      if (!BASE.Hub.config.inputJax) {HUB.config.inputJax = {}}
      HUB.config.inputJax[mimetype] = this;
    }
  },{
    version: 1.0,
    directory: JAX.directory+"/input",
    extensionDir: JAX.extensionDir
  });

  /***********************************/

  BASE.OutputJax = JAX.Subclass({
    Register: function (mimetype) {
      if (!HUB.config.outputJax) {HUB.config.outputJax = {}}
      if (!HUB.config.outputJax[mimetype]) {HUB.config.outputJax[mimetype] = []}
      HUB.config.outputJax[mimetype].push(this);
    },
    Remove: function (jax) {}
  },{
    version: 1.0,
    directory: JAX.directory+"/output",
    extensionDir: JAX.extensionDir,
    fontDir: "["+BASENAME+"]/fonts"
  });
  
  /***********************************/

  BASE.ElementJax = JAX.Subclass({
    inputJax: null,
    outputJax: null,
    inputID: null,
    originalText: "",
    mimeType: "",
    
    Text: function (text,callback) {
      this.outputJax.Remove(this);
      var script = this.SourceElement();
      if (script.firstChild) {
        if (script.firstChild.nodeName !== "#text") {script.text = text}
          else {script.firstChild.nodeValue = text}
      } else {try {script.innerHTML = text} catch(err) {script.text = text}}
      script.MathJax.state = this.STATE.UPDATE;
      HUB.Update(script,callback);
    },
    Reprocess: function (callback) {
      var script = this.SourceElement();
      script.MathJax.state = this.STATE.UPDATE;
      HUB.Reprocess(script,callback);
    },
    Remove: function () {
      this.outputJax.Remove(this);
      HUB.signal.Post(["Remove Math",this.inputID]); // wait for this to finish?
      this.Detach();
    },

    SourceElement: function () {return document.getElementById(this.inputID)},
    
    Attach: function (script,inputJax) {
      var jax = script.MathJax.elementJax;
      if (script.MathJax.state === this.STATE.UPDATE) {
        jax.Clone(this);
      } else {
        jax = script.MathJax.elementJax = this;
        if (script.id) {this.inputID = script.id}
          else {script.id = this.inputID = BASE.ElementJax.GetID(); this.newID = 1}
      }
      jax.originalText = (script.text == "" ? script.innerHTML : script.text);
      jax.inputJax = inputJax;
    },
    Detach: function () {
      var script = this.SourceElement(); if (!script) return;
      try {delete script.MathJax} catch(err) {script.MathJax = null}
      if (this.newID) {script.id = ""}
    },
    Clone: function (jax) {
      for (var id in this) {
        if (!this.hasOwnProperty(id)) continue;
        if (typeof(jax[id]) === 'undefined' && id !== 'newID') {delete this[id]}
      }
      for (var id in jax) {
        if (!this.hasOwnProperty(id)) continue;
        if (typeof(this[id]) === 'undefined' || (this[id] !== jax[id] && id !== 'inputID'))
          {this[id] = jax[id]}
      }
    }
  },{
    version: 1.0,
    directory: JAX.directory+"/element",
    extensionDir: JAX.extensionDir,
    ID: 0,  // jax counter (for IDs)
    STATE: {
      PENDING: 1,      // script is identified as math but not yet processed
      PROCESSED: 2,    // script has been processed
      UPDATE: 3        // elementJax should be updated
    },
    
    GetID: function () {this.ID++; return "MathJax-Element-"+this.ID},
    Subclass: function () {
      var obj = JAX.Subclass.apply(this,arguments);
      obj.loadComplete = this.prototype.loadComplete;
      return obj;
    }
  });
  BASE.ElementJax.prototype.STATE = BASE.ElementJax.STATE;
  
})("MathJax");

/**********************************************************/

(function (BASENAME) {
  var BASE = window[BASENAME];
  if (!BASE) {BASE = window[BASENAME] = {}}

  var HUB = BASE.Hub; var STARTUP = HUB.Startup; var CONFIG = HUB.config;
  var HEAD = document.getElementsByTagName("head")[0];
  if (!HEAD) {HEAD = document.childNodes[0]};
  var scripts = (document.documentElement || document).getElementsByTagName("script");
  var namePattern = new RegExp("(^|/)"+BASENAME+"\\.js$");
  for (var i = scripts.length-1; i >= 0; i--) {
    if (scripts[i].src.match(namePattern)) {
      STARTUP.script = scripts[i].innerHTML;
      CONFIG.root = scripts[i].src.replace(/(^|\/)[^\/]*$/,'');
      break;
    }
  }
  BASE.Ajax.config = CONFIG;

  var BROWSERS = {
    isMac:       (navigator.platform.substr(0,3) === "Mac"),
    isPC:        (navigator.platform.substr(0,3) === "Win"),
    isMSIE:      (document.all != null && !window.opera),
    isFirefox:   (document.ATTRIBUTE_NODE != null && window.directories != null),
    isSafari:    (navigator.vendor != null && navigator.vendor.match(/Apple/) != null && !navigator.omniWebString),
    isOpera:     (window.opera != null && window.opera.version != null),
    isChrome:    (navigator.vendor != null && navigator.vendor.match(/Google/) != null),
    isKonqueror: (window.hasOwnProperty && window.hasOwnProperty("konqueror")),
    versionAtLeast: function (v) {
      var bv = (this.version).split('.'); v = (new String(v)).split('.');
      for (var i = 0, m = v.length; i < m; i++)
        {if (bv[i] != v[i]) {return parseInt(bv[i]||"0") >= parseInt(v[i])}}
      return true;
    },
    Select: function (choices) {
      var browser = choices[HUB.Browser];
      if (browser) {return browser(HUB.Browser)}
      return null;
    }
  };

  var AGENT = navigator.userAgent
    .replace(/^Mozilla\/(\d+\.)+\d+ /,"")                                   // remove initial Mozilla, which is never right
    .replace(/[a-z][-a-z0-9._: ]+\/\d+[^ ]*-[^ ]*\.([a-z][a-z])?\d+ /i,"")  // remove linux version
    .replace(/Gentoo |Ubuntu\/(\d+\.)*\d+ (\([^)]*\) )?/,"");               // special case for these

  HUB.Browser = HUB.Insert(HUB.Insert(new String("Unknown"),{version: "0.0"}),BROWSERS);
  for (var browser in BROWSERS) {if (BROWSERS.hasOwnProperty(browser)) {
    if (BROWSERS[browser] && browser.substr(0,2) === "is") {
      browser = browser.slice(2);
      if (browser === "Mac" || browser === "PC") continue;
      HUB.Browser = HUB.Insert(new String(browser),BROWSERS);
      var VERSION = new RegExp(
        ".*(Version)/((?:\\d+\\.)+\\d+)|" +                                       // for Safari and Opera10
        ".*("+browser+")"+(browser == "MSIE" ? " " : "/")+"((?:\\d+\\.)*\\d+)|"+  // for one of the main browser
        "(?:^|\\(| )([a-z][-a-z0-9._: ]+)/((?:\\d+\\.)+\\d+)");                   // for unrecognized browser
      var MATCH = VERSION.exec(AGENT) || ["","","","unknown","0.0"];
      HUB.Browser.name = (MATCH[1] == "Version" ? browser : (MATCH[3] || MATCH[5]));
      HUB.Browser.version = MATCH[2] || MATCH[4] || MATCH[6];
      break;
    }
  }};
  
  //
  //  Initial browser-specific info (e.g., touch up version or name)
  //
  HUB.Browser.Select({
    Safari: function (browser) {
      var v = parseInt((String(browser.version).split("."))[0]);
      if      (v >= 526) {browser.version = "4.0"}
      else if (v >= 525) {browser.version = "3.1"}
      else if (v >  500) {browser.version = "3.0"}
      else if (v >  400) {browser.version = "2.0"}
      else if (v >   85) {browser.version = "1.0"}
    },
    Firefox: function (browser) {
      if (browser.version === "0.0" && navigator.product === "Gecko" && navigator.productSub) {
        var date = navigator.productSub.substr(0,8);
        if      (date >= "20090630") {browser.version = "3.5"}
        else if (date >= "20080617") {browser.version = "3.0"}
        else if (date >= "20061024") {browser.version = "2.0"}
      }
    },
    Opera: function (browser) {browser.verion = opera.version()}
  });
  HUB.Browser.Select(MathJax.Message.browsers);

  BASE.CallBack.Queue(
    ["Post",STARTUP.signal,"Begin"],
    ["Config",STARTUP],
    ["Styles",STARTUP],
    ["Jax",STARTUP],
    ["Extensions",STARTUP],
    STARTUP.onLoad(),
    ["Browser",STARTUP],
    function () {MathJax.isReady = true}, // indicates that MathJax is ready to process math
    ["Typeset",STARTUP],
    ["Post",STARTUP.signal,"End"]
  );
  
})("MathJax");

}

/**********************************************************/
