/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/GeneralPunctuation.js
 *
 *  Copyright (c) 2009 Design Science, Inc.
 *
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
 *
 */

MathJax.Hub.Insert(
  MathJax.OutputJax['HTML-CSS'].FONTDATA.FONTS['MathJax_Main'],
  {
    0x2006: [0,0,167,0,0],             // ??
    0x2013: [285,-248,500,0,499],      // EN DASH
    0x2014: [285,-248,1000,0,999],     // EM DASH
    0x2018: [694,-379,278,64,198],     // LEFT SINGLE QUOTATION MARK
    0x2019: [694,-379,278,78,212],     // RIGHT SINGLE QUOTATION MARK
    0x201C: [694,-379,500,128,466],    // LEFT DOUBLE QUOTATION MARK
    0x201D: [694,-379,500,34,372],     // RIGHT DOUBLE QUOTATION MARK
    0x2020: [705,217,444,55,390],      // DAGGER
    0x2021: [705,206,444,55,389],      // DOUBLE DAGGER
    0x2026: [120,0,1172,78,1093],      // HORIZONTAL ELLIPSIS
    0x2032: [560,-43,275,30,262]       // PRIME
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/GeneralPunctuation.js");
