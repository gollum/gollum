/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/SansSerif/Bold/Other.js
 *
 *  Copyright (c) 2009-2010 Design Science, Inc.
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
  MathJax.OutputJax['HTML-CSS'].FONTDATA.FONTS['MathJax_SansSerif-bold'],
  {
    0xA0: [0,0,250,0,0],               // NO-BREAK SPACE
    0x131: [459,1,256,54,201],         // LATIN SMALL LETTER DOTLESS I
    0x237: [459,205,286,-71,232],      // LATIN SMALL LETTER DOTLESS J
    0x393: [692,1,581,92,535],         // GREEK CAPITAL LETTER GAMMA
    0x394: [695,0,917,60,856],         // GREEK CAPITAL LETTER DELTA
    0x398: [716,22,856,62,793],        // GREEK CAPITAL LETTER THETA
    0x39B: [695,1,672,41,630],         // GREEK CAPITAL LETTER LAMDA
    0x39E: [688,1,733,45,687],         // GREEK CAPITAL LETTER XI
    0x3A0: [691,1,794,92,702],         // GREEK CAPITAL LETTER PI
    0x3A3: [695,0,794,61,733],         // GREEK CAPITAL LETTER SIGMA
    0x3A5: [716,1,856,61,794],         // GREEK CAPITAL LETTER UPSILON
    0x3A6: [695,0,794,62,732],         // GREEK CAPITAL LETTER PHI
    0x3A8: [695,0,856,61,794],         // GREEK CAPITAL LETTER PSI
    0x3A9: [716,1,794,48,745],         // GREEK CAPITAL LETTER OMEGA
    0x2013: [327,-240,550,0,549],      // EN DASH
    0x2014: [327,-240,1100,0,1099],    // EM DASH
    0x2018: [695,-443,306,81,226],     // LEFT SINGLE QUOTATION MARK
    0x2019: [694,-441,306,80,226],     // RIGHT SINGLE QUOTATION MARK
    0x201C: [695,-443,558,138,521],    // LEFT DOUBLE QUOTATION MARK
    0x201D: [694,-441,558,37,420]      // RIGHT DOUBLE QUOTATION MARK
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/SansSerif/Bold/Other.js");
