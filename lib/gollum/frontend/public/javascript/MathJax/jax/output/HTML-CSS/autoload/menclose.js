/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/autoload/menclose.js
 *  
 *  Implements the HTML-CSS output for <mencode> elements.
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
  
  MML.menclose.Augment({
    toHTML: function (span) {
      var values = this.getValues("notation","thickness","padding");
      if (values.thickness == null) {values.thickness = ".1em"}
      if (values.padding == null)   {values.padding   = ".25em"}
      var p = HTMLCSS.length2em(values.padding);
      var t = HTMLCSS.length2em(values.thickness);
      if (t !== 0 && t < 1.25/HTMLCSS.em) {t = 1.25/HTMLCSS.em}
      var T = (HTMLCSS.msieBorderWidthBug ? 0 : t);
      // FIXME:  handle other notations
      span = this.HTMLcreateSpan(span);
      var stack = HTMLCSS.createStack(span);
      var base = HTMLCSS.createBox(stack), box = HTMLCSS.createBox(stack);
      HTMLCSS.Measured(this.data[0].toHTML(base),base);
      box.bbox = {w:base.bbox.w+2*(p+t), h:base.bbox.h+base.bbox.d+2*(p+t), d:0,
                 lw:0, rw:base.bbox.w+2*(p+t)};
      var frame = HTMLCSS.addElement(box,"span",{style:{
        display:"inline-block", overflow:"hidden",
        border:HTMLCSS.Em(t)+" solid",
        width:HTMLCSS.Em(box.bbox.w-2*T), height:HTMLCSS.Em(box.bbox.h-2*T)
      }});
      if (HTMLCSS.msieInlineBlockAlignBug)
        {frame.style.verticalAlign = HTMLCSS.Em(HTMLCSS.getHD(span.parentNode).d)}
      HTMLCSS.placeBox(box,0,-p-t-base.bbox.d);
      HTMLCSS.placeBox(base,p+t,0);
      this.HTMLhandleSpace(span);
      this.HTMLhandleColor(span);
      return span;
    }
  });
  
  MathJax.Hub.Startup.signal.Post("HTML-CSS menclose Ready");
  MathJax.Ajax.loadComplete(HTMLCSS.autoloadDir+"/menclose.js");
  
})(MathJax.ElementJax.mml,MathJax.OutputJax["HTML-CSS"]);

