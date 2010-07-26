/*************************************************************
 *
 *  MathJax/extensions/MMLorHTML.js
 *  
 *  Chooses between the NativeMML and HTML-CSS output jax depending
 *  on the capabilities of the browser and configuration settings
 *  of the page.
 *  
 *  This file should be added to the config array when configuring
 *  MathJax.  Note that if you include this, you should NOT include
 *  an output jax in the jax array (it will be added for you by
 *  this file).
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

(function (HUB) {
  var CONFIG = MathJax.Hub.Insert({prefer: "HTML"},(MathJax.Hub.config.MMLorHTML||{}));

  var MINBROWSERVERSION = {
    Firefox: 3.0,
    Opera: 9.52,
    MSIE: 6.0,
    Chrome: 0.3,
    Safari: 2.0,
    Konqueror: 4.0
  };

  var canUseHTML = (HUB.Browser.version === "0.0" ||
                    HUB.Browser.versionAtLeast(MINBROWSERVERSION[HUB.Browser]||0.0));

  var MathPlayer; try {new ActiveXObject("MathPlayer.Factory.1"); MathPlayer = true} catch(err) {MathPlayer = false};

  var canUseMML = (HUB.Browser.isFirefox && HUB.Browser.versionAtLeast("1.5")) ||
                  (HUB.Browser.isMSIE && MathPlayer) ||
                  (HUB.Browser.isOpera && HUB.Browser.versionAtLeast("9.52"));
  if (canUseHTML || canUseMML) {
    if (canUseMML && (CONFIG.prefer === "MML" || !canUseHTML))
      {HUB.config.jax.push("output/NativeMML")} else {HUB.config.jax.push("output/HTML-CSS")}
  } else {
    HUB.PreProcess.disabled = true;
    HUB.prepareScripts.disabled = true;
    MathJax.Message.Set("Your browser does not support MathJax",null,4000);
    HUB.Startup.signal.Post("MathJax not supported");
  }

})(MathJax.Hub);

MathJax.Ajax.loadComplete("[MathJax]/config/MMLorHTML.js");
