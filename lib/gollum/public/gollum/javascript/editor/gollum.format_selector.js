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
      FS.setMarkupMode(newValue);
      $gollum_editor.focus();
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
    * FormatSelector.setMarkupMode
    * Set ace editor mode
    */
    setMarkupMode: function( newMode ) {
      debug('setting Markup Mode ' + newMode);
      // Do not change newMode for the modes that ace recognizes, change it to 'text' for the others
      switch ( newMode ) {
        case 'markdown':
        break;
        case 'asciidoc':
        break;
        case 'textile':
        break;
        case 'rdoc':
        break;
        default:
        newMode = 'text';
      };
      $gollum_editor.getSession().setMode("ace/mode/" + newMode);
    },

    /**
    * FormatSelector.update
    */
    updateSelected: function() {
      var currentLang = $.LanguageDefinition.getActiveLanguage();
      FS.setMarkupMode( currentLang );
      FS.$_SELECTOR.val(currentLang);
    }

  };

  if (!onChange) {
    onChange = FS.defaultOnChange;
  }

  FS.init(selector);

  return FS;

};
