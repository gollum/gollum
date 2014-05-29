/**
*  FormatSelector
*
*  Functions relating to the format selector (if it exists)
*/

var FormatSelector = function($, selector, onChange, debuggingActive){

  if (!debuggingActive) debuggingActive = false;

  var debug = function(m) {
    if (debuggingActive && typeof console != 'undefined') {
      console.log( m );
    }
  };

  var FS = {

    defaultOnChange: function(newValue) {
      FS.updateCommitMessage(newValue);
      $.LanguageDefinition.setActiveLanguage(newValue);
    },

    $_SELECTOR: null,

    /**
    *  FormatSelector.evtChangeFormat
    *  Event handler for when a format has been changed by the format
    *  selector. Will automatically load a new language definition
    *  via JS if necessary.
    *
    *  @return void
    */
    evtChangeFormat: function(e) {
      onChange($(this).val());
    },

    updateCommitMessage: function( newMarkup ) {
      var msg = document.getElementById( "gollum-editor-message-field" );
      var val = msg.value;
      // Must start with created or updated.
      if (/^(?:created|updated)/i.test(val)) {
        msg.value = val.replace( /\([^\)]*\)$/, "(" + newMarkup + ")" );
      }
    },

    /**
    *  FormatSelector.init
    *  Initializes the format selector.
    *
    *  @return void
    */
    init: function( $sel ) {
      debug('Initializing format selector');

      // unbind events if init is being called twice for some reason
      if (FS.$_SELECTOR && typeof FS.$_SELECTOR == 'object') {
        FS.$_SELECTOR.unbind('change');
      }

      FS.$_SELECTOR = $sel;

      // set format selector to the current language
      FS.updateSelected();
      FS.$_SELECTOR.change(FS.evtChangeFormat);
    },


    /**
    * FormatSelector.update
    */
    updateSelected: function() {
      var currentLang = $.LanguageDefinition.getActiveLanguage();
      FS.$_SELECTOR.val(currentLang);
    }

  };

  if (!onChange) {
    onChange = FS.defaultOnChange;
  }

  FS.init(selector);

  return FS;

};
