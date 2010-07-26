/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/autoload/mglyph.js
 *  
 *  Implements the HTML-CSS output for <mglyph> elements.
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

(function (MML,HTMLCSS) {
  
  MML.mglyph.Augment({
    toHTML: function (span,variant) {
      var values = this.getValues("src","width","height","valign","alt");
      if (values.src === "") {
        values = this.getValues("index");
        variant = this.HTMLgetVariant();
        if (values.index) {this.HTMLhandleVariant(span,variant,String.fromCharCode(values.index))}
      } else {
        if (!this.img) {this.img = MML.mglyph.GLYPH[values.src]}
        if (!this.img) {
          this.img = MML.mglyph.GLYPH[values.src] = {img: new Image(), status: "pending"};
          var img = this.img.img;
          img.onload = MathJax.CallBack(["HTMLimgLoaded",this]);
          img.onerror = MathJax.CallBack(["HTMLimgError",this]);
          img.src = values.src;
          MathJax.Hub.RestartAfter(img.onload);
        }
        var SPAN = span;
        if (this.img.status !== "OK") {
          var span = HTMLCSS.addElement(span,"span",{className:"merror", style:{fontSize:"75%"}});
          HTMLCSS.addText(span,"Bad mglyph: "+values.src);
          span.bbox = {lw:0, w:span.offsetWidth/HTMLCSS.em, h:.8, d:.2};
          span.bbox.rw = span.bbox.w;
        } else {
          span = this.HTMLcreateSpan(span);
          img = HTMLCSS.addElement(span,"img",{src:values.src, alt:values.alt, title:values.alt});
          if (values.width)  {
            if (String(values.width).match(/^\s*-?\d+\s*$/)) {values.width += "px"}
            img.style.width = HTMLCSS.Em(HTMLCSS.length2em(values.width,this.img.img.width/HTMLCSS.em));
          }
          if (values.height) {
            if (String(values.height).match(/^\s*-?\d+\s*$/)) {values.height += "px"}
            img.style.height = HTMLCSS.Em(HTMLCSS.length2em(values.height,this.img.img.height/HTMLCSS.em));
          }
          span.bbox.w = span.bbox.rw = img.offsetWidth/HTMLCSS.em;
          span.bbox.h = img.offsetHeight/HTMLCSS.em;
          if (values.valign) {
            if (String(values.valign).match(/^\s*-?\d+\s*$/)) {values.valign += "px"}
            span.bbox.d = -HTMLCSS.length2em(values.valign,this.img.img.height/HTMLCSS.em);
            img.style.verticalAlign = HTMLCSS.Em(-span.bbox.d);
            span.bbox.h -= span.bbox.d;
          }
        }
        if (variant) {
          if (!SPAN.bbox) {
            SPAN.bbox = {w: span.bbox.w, h: span.bbox.h, d: span.bbox.d,
                         rw: span.bbox.rw, lw: span.bbox.lw};
          } else {
            SPAN.bbox.w += span.bbox.w;
            if (SPAN.bbox.w > SPAN.bbox.rw) {SPAN.bbox.rw = SPAN.bbox.w}
            if (span.bbox.h > SPAN.bbox.h) {SPAN.bbox.h = span.bbox.h}
            if (span.bbox.d > SPAN.bbox.d) {SPAN.bbox.d = span.bbox.d}
          }
        }
      }
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    },
    HTMLimgLoaded: function (event,status) {
      if (typeof(event) === "string") {status = event}
      this.img.status = (status || "OK")
    },
    HTMLimgError: function () {this.img.img.onload("error")}
  },{
    GLYPH: {}    // global list of all loaded glyphs
  });
  
  MathJax.Hub.Startup.signal.Post("HTML-CSS mglyph Ready");
  MathJax.Ajax.loadComplete(HTMLCSS.autoloadDir+"/mglyph.js");
  
})(MathJax.ElementJax.mml,MathJax.OutputJax["HTML-CSS"]);

