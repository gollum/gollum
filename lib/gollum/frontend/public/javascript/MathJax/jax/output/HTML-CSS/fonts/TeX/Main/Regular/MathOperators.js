/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/MathOperators.js
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
    0x2200: [694,22,556,0,556],        // FOR ALL
    0x2202: [715,22,531,41,566],       // PARTIAL DIFFERENTIAL
    0x2203: [694,0,556,55,500],        // THERE EXISTS
    0x2205: [772,78,500,39,460],       // EMPTY SET
    0x2207: [683,33,833,46,786],       // NABLA
    0x2208: [541,41,667,84,584],       // ELEMENT OF
    0x2209: [716,215,667,84,584],      // stix-negated (vert) set membership, variant
    0x220B: [541,40,667,83,582],       // CONTAINS AS MEMBER
    0x2212: [270,-230,778,83,694],     // MINUS SIGN
    0x2213: [500,167,778,55,722],      // MINUS-OR-PLUS SIGN
    0x2215: [751,250,500,56,445],      // DIVISION SLASH
    0x2216: [750,250,500,56,444],      // SET MINUS
    0x2217: [465,-34,500,64,435],      // ASTERISK OPERATOR
    0x2218: [444,-55,500,55,444],      // RING OPERATOR
    0x2219: [444,-55,500,55,444],      // BULLET OPERATOR
    0x221A: [800,200,833,72,853],      // SQUARE ROOT
    0x221D: [442,11,778,56,722],       // PROPORTIONAL TO
    0x221E: [442,11,1000,55,944],      // INFINITY
    0x2220: [694,0,722,55,666],        // ANGLE
    0x2223: [750,250,278,119,159],     // DIVIDES
    0x2225: [750,250,500,132,367],     // PARALLEL TO
    0x2227: [598,22,667,55,611],       // LOGICAL AND
    0x2228: [598,22,667,55,611],       // LOGICAL OR
    0x2229: [598,22,667,55,611],       // stix-intersection, serifs
    0x222A: [599,22,667,55,611],       // stix-union, serifs
    0x222B: [716,216,417,55,472],      // INTEGRAL
    0x223C: [367,-133,778,55,722],     // TILDE OPERATOR
    0x2240: [583,83,278,55,222],       // WREATH PRODUCT
    0x2243: [464,-36,778,55,722],      // ASYMPTOTICALLY EQUAL TO
    0x2245: [589,-22,1000,55,722],     // APPROXIMATELY EQUAL TO
    0x2248: [483,-55,778,55,722],      // ALMOST EQUAL TO
    0x224D: [484,-16,778,55,722],      // EQUIVALENT TO
    0x2250: [670,-133,778,55,722],     // APPROACHES THE LIMIT
    0x2260: [716,215,778,55,722],      // stix-not (vert) equals
    0x2261: [464,-36,778,55,722],      // IDENTICAL TO
    0x2264: [636,138,778,83,694],      // LESS-THAN OR EQUAL TO
    0x2265: [636,138,778,82,694],      // GREATER-THAN OR EQUAL TO
    0x226A: [568,68,1000,56,944],      // MUCH LESS-THAN
    0x226B: [567,67,1000,55,945],      // MUCH GREATER-THAN
    0x227A: [539,41,778,84,695],       // PRECEDES
    0x227B: [539,41,778,83,694],       // SUCCEEDS
    0x2282: [540,41,778,84,695],       // SUBSET OF
    0x2283: [541,40,778,82,693],       // SUPERSET OF
    0x2286: [636,139,778,84,695],      // SUBSET OF OR EQUAL TO
    0x2287: [637,138,778,83,693],      // SUPERSET OF OR EQUAL TO
    0x228E: [599,22,667,55,611],       // MULTISET UNION
    0x2291: [636,138,778,83,714],      // SQUARE IMAGE OF OR EQUAL TO
    0x2292: [636,138,778,63,694],      // SQUARE ORIGINAL OF OR EQUAL TO
    0x2293: [598,0,667,61,605],        // stix-square intersection, serifs
    0x2294: [598,0,667,61,605],        // stix-square union, serifs
    0x2295: [583,83,778,56,722],       // stix-circled plus (with rim)
    0x2296: [583,83,778,56,722],       // CIRCLED MINUS
    0x2297: [583,83,778,56,722],       // stix-circled times (with rim)
    0x2298: [583,83,778,56,722],       // CIRCLED DIVISION SLASH
    0x2299: [583,83,778,56,722],       // CIRCLED DOT OPERATOR
    0x22A2: [694,0,611,55,555],        // RIGHT TACK
    0x22A3: [694,0,611,55,555],        // LEFT TACK
    0x22A4: [668,0,778,55,723],        // DOWN TACK
    0x22A5: [668,0,778,55,723],        // UP TACK
    0x22A8: [750,250,867,119,811],     // TRUE
    0x22C4: [488,-12,500,12,488],      // DIAMOND OPERATOR
    0x22C5: [310,-190,278,78,199],     // DOT OPERATOR
    0x22C6: [486,-16,500,3,497],       // STAR OPERATOR
    0x22C8: [505,6,900,25,873],        // BOWTIE
    0x22EE: [900,30,278,78,199],       // VERTICAL ELLIPSIS
    0x22EF: [310,-190,1172,78,1093],   // MIDLINE HORIZONTAL ELLIPSIS
    0x22F1: [820,-100,1282,133,1148]   // DOWN RIGHT DIAGONAL ELLIPSIS
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/MathOperators.js");
