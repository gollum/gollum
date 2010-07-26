/*************************************************************
 *
 *  MathJax/jax/output/HTML-CSS/fonts/TeX/Main/Regular/Arrows.js
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
    0x2190: [511,12,1000,54,944],      // LEFTWARDS ARROW
    0x2191: [694,194,500,17,483],      // UPWARDS ARROW
    0x2192: [512,11,1000,55,945],      // RIGHTWARDS ARROW
    0x2193: [694,194,500,17,483],      // DOWNWARDS ARROW
    0x2194: [511,11,1000,55,945],      // LEFT RIGHT ARROW
    0x2195: [772,272,500,17,483],      // UP DOWN ARROW
    0x2196: [720,196,1000,29,944],     // NORTH WEST ARROW
    0x2197: [720,195,1000,55,970],     // NORTH EAST ARROW
    0x2198: [695,220,1000,55,970],     // SOUTH EAST ARROW
    0x2199: [695,220,1000,29,944],     // SOUTH WEST ARROW
    0x21A6: [512,11,1000,54,945],      // RIGHTWARDS ARROW FROM BAR
    0x21A9: [511,12,1126,54,1070],     // LEFTWARDS ARROW WITH HOOK
    0x21AA: [512,11,1126,55,1071],     // RIGHTWARDS ARROW WITH HOOK
    0x21BC: [511,-230,1000,55,944],    // LEFTWARDS HARPOON WITH BARB UPWARDS
    0x21BD: [270,11,1000,55,944],      // LEFTWARDS HARPOON WITH BARB DOWNWARDS
    0x21C0: [511,-230,1000,55,944],    // RIGHTWARDS HARPOON WITH BARB UPWARDS
    0x21C1: [270,11,1000,55,945],      // RIGHTWARDS HARPOON WITH BARB DOWNWARDS
    0x21CC: [671,11,1000,55,944],      // RIGHTWARDS HARPOON OVER LEFTWARDS HARPOON
    0x21D0: [525,24,1000,55,944],      // LEFTWARDS DOUBLE ARROW
    0x21D1: [694,194,611,31,579],      // UPWARDS DOUBLE ARROW
    0x21D2: [525,25,1000,55,944],      // RIGHTWARDS DOUBLE ARROW
    0x21D3: [694,194,611,31,579],      // DOWNWARDS DOUBLE ARROW
    0x21D4: [525,25,1000,34,966],      // LEFT RIGHT DOUBLE ARROW
    0x21D5: [772,272,611,31,580]       // UP DOWN DOUBLE ARROW
  }
);

MathJax.Ajax.loadComplete(MathJax.OutputJax["HTML-CSS"].fontDir + "/Main/Regular/Arrows.js");
