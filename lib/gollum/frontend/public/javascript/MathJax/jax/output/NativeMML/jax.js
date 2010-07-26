/*************************************************************
 *
 *  MathJax/jax/output/NativeMML/jax.js
 *
 *  Implements the NativeMML OutputJax that displays mathematics
 *  using a browser's native MathML capabilities (if any).
 *  
 *  ---------------------------------------------------------------------
 *  
 *  Copyright (c) 2010 Design Science, Inc.
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

(function (MML,nMML) {
  
  nMML.Augment({
    //
    //  User can configure styles
    //
    config: {styles: {}},
    Startup: function () {return MathJax.Ajax.Styles(this.config.styles)},
    //
    //  Add a SPAN to use as a container, and render the math into it
    //  
    Translate: function (script) {
      var math = script.MathJax.elementJax.root;
      var type = (math.Get("display") === "block" ? "div" : "span");
      var span = script.parentNode.insertBefore(document.createElement(type),script);
      span.className = "MathJax_MathML";
      try {math.toNativeMML(span)} catch (err) {
        if (err.restart) {span.parentNode.removeChild(span)}
        throw err;
      }
    },
    //
    //  Remove MathML preceeding the script
    //
    Remove: function (jax) {
      var span = jax.SourceElement(); if (!span) return;
      span = span.previousSibling; if (!span) return;
      if (span.className.match(/MathJax_MathML/)) {span.parentNode.removeChild(span)}
    },
    //
    //  The namespace to use for MML
    //
    MMLnamespace: "http://www.w3.org/1998/Math/MathML"
  });
  
  MML.mbase.Augment({
    //
    //  Add a MathML tag of the correct type, and set its attributes
    //    then populate it with its children and append it to the parent
    //
    toNativeMML: function (parent) {
      var tag = this.NativeMMLelement(this.type);
      this.NativeMMLattributes(tag);
      for (var i = 0, m = this.data.length; i < m; i++) {
        if (this.data[i]) {this.data[i].toNativeMML(tag)}
          else {tag.appendChild(this.NativeMMLelement("mrow"))}
      }
      parent.appendChild(tag);
    },
    //
    //  Look for attributes that are different from the defaults
    //    and set those in the tag's attribute list
    //
    NativeMMLattributes: function (tag) {
      var defaults = this.defaults, id;
      var copy = this.NativeMMLcopyAttributes,
          skip = this.NativeMMLskipAttributes;
      if (this.type === "mstyle") {defaults = MML.math.prototype.defaults}
      for (var id in defaults) {if (!skip[id] && defaults.hasOwnProperty(id)) {
        if (this[id] != null) {tag.setAttribute(id,String(this[id]))}
      }}
      for (var i = 0, m = copy.length; i < m; i++) {
        if (this[copy[i]] != null) {tag.setAttribute(copy[i],String(this[copy[i]]))}
      }
      if (this.style) {tag.setAttribute("style",this.style)}
    },
    NativeMMLcopyAttributes: [
      "fontfamily","fontsize","fontweight","fontstyle",
      "color","background",
      "id","class","href","style"
    ],
    NativeMMLskipAttributes: {texClass: 1, useHeight: 1, texprimestyle: 1},
    //
    //  Create a MathML element
    //
    NativeMMLelement: (
      MathJax.Hub.Browser.isMSIE ?
        function (type) {return document.createElement("mjx:"+type)} :
        function (type) {return document.createElementNS(nMML.MMLnamespace,type)}
    )
  });
  
  MML.mrow.Augment({
    //
    //  Make inferred rows not include an mrow tag
    //
    toNativeMML: function (parent) {
      if (this.inferred  && this.parent.inferRow) {
        for (var i = 0, m = this.data.length; i < m; i++) {
          if (this.data[i]) {this.data[i].toNativeMML(parent)}
            else {parent.appendChild(this.NativeMMLelement("mrow"))}
        }
      } else {
        this.SUPER(arguments).toNativeMML.call(this,parent);
      }
    }
  });
  
  MML.msubsup.Augment({
    //
    //  Use proper version of msub, msup, or msubsup, depending on
    //  which items are present
    //
    toNativeMML: function (parent) {
      var type = this.type;
      if (this.data[this.sup] == null) {type = "msub"}
      if (this.data[this.sub] == null) {type = "msup"}
      var tag = this.NativeMMLelement(type);
      this.NativeMMLattributes(tag);
      delete this.data[0].inferred;
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toNativeMML(tag)}}
      parent.appendChild(tag);
    }
  });
  
  MML.munderover.Augment({
    //
    //  Use proper version of munder, mover, or munderover, depending on
    //  which items are present
    //
    toNativeMML: function (parent) {
      var type = this.type;
      if (this.data[this.under] == null) {type = "mover"}
      if (this.data[this.over] == null)  {type = "munder"}
      var tag = this.NativeMMLelement(type);
      this.NativeMMLattributes(tag);
      delete this.data[0].inferred;
      for (var i = 0, m = this.data.length; i < m; i++)
        {if (this.data[i]) {this.data[i].toNativeMML(tag)}}
      parent.appendChild(tag);
    }
  });
  
  if (MathJax.Hub.Browser.isFirefox) {
    MML.mtable.Augment({
      toNativeMML: function (parent) {
        //
        //  FF doesn't handle width, so put it in styles instead
        //
        if (this.width) {
          var styles = (this.style||"").replace(/;\s*$/,"").split(";");
          styles.push("width:"+this.width);
          this.style = styles.join(";");
        }
        this.SUPER(arguments).toNativeMML.call(this,parent);
      }
    });
    MML.mlabeledtr.Augment({
      toNativeMML: function (parent) {
        //
        //  FF doesn't handle mlabeledtr, so remove the label
        //
        var tag = this.NativeMMLelement("mtr");
        this.NativeMMLattributes(tag);
        for (var i = 1, m = this.data.length; i < m; i++) {
          if (this.data[i]) {this.data[i].toNativeMML(tag)}
          else {tag.appendChild(this.NativeMMLelement("mrow"))}
        }
        parent.appendChild(tag);
      }
    });
  }
  
  MML.TeXAtom.Augment({
    //
    //  Convert TeXatom to an mrow
    //
    toNativeMML: function (parent) {
      // FIXME:  Handle spacing using mpadded?
      var tag = this.NativeMMLelement("mrow");
      this.data[0].toNativeMML(tag);
      parent.appendChild(tag);
    }
  });
  
  MML.chars.Augment({
    //
    //  Add a text node
    //
    toNativeMML: function (parent) {
      parent.appendChild(document.createTextNode(this.toString()));
    }
  });
  
  MML.entity.Augment({
    //
    //  Add a text node
    //
    toNativeMML: function (parent) {
      parent.appendChild(document.createTextNode(this.toString()));
    }
  });
  
  MathJax.Hub.Register.StartupHook("TeX mathchoice Ready",function () {
    MML.TeXmathchoice.Augment({
      //
      //  Get the MathML for the selected choice
      //
      toNativeMML: function (parent) {this.Core().toNativeMML(parent)}
    });
  });
  
  nMML.loadComplete("jax.js");

})(MathJax.ElementJax.mml, MathJax.OutputJax.NativeMML);
