/**
 *  gollum.editor.js
 *  A jQuery plugin that creates the Gollum Editor.
 *
 *  Usage:
 *  $.GollumEditor(); on DOM ready.
**/
/* (function($) { */
  
  var GollumDefaults = {
    MarkupType: 'markdown',
    EditorMode: 'code',
    HasFunctionBar: true,
    Debug: true
  };
  
  var ActiveOptions = {};
  
  $.GollumEditor = function(options) {
    
    ActiveOptions = $.extend(GollumDefaults, options); 
    debug('GollumEditor loading');
    
    if ( EditorHas.baseEditorMarkup() ) {
      
      // Initialise the function bar by loading proper definitions
      if ( EditorHas.functionBar() ) {
        var htmlSetMarkupLang =
          $('#gollum-editor-body').attr('data-markup-lang');
        
        if ( htmlSetMarkupLang ) {
          ActiveOptions.MarkupType = htmlSetMarkupLang;
        }

        if ( !LanguageDefinition.isLoadedFor(ActiveOptions.MarkupType) ) {
          debug('Loading language definition for ' + ActiveOptions.MarkupType);
          LanguageDefinition.loadFor(ActiveOptions.MarkupType, 
            function(data, textStatus) { 
              if (textStatus != 'success') {
                debug('Language definition could not be loaded for markup '
                      + 'type ' + ActiveOptions.MarkupType);
                return;
              }
              // activate the function bar
              FunctionBar.activate();
            });
        }
      }
      
    }
  };
  
  $.GollumEditor.defineLanguage = function( language_name, languageObject ) {
    if ( typeof languageObject == 'object' )
      LanguageDefinition.define( language_name, languageObject );
    else 
      debug('GollumEditor.defineLanguage: definition for ' + language_name 
            + ' is not an object');
  };
  
  
  
  /**
   *  debug
   *  Prints debug information to console.log if debug output is enabled.
   *  
   *  @param  mixed  Whatever you want to dump to console.log
   *  @return void
  **/
  var debug = function(m) {
    if ( ActiveOptions.Debug && console 
         && typeof console.log == 'function' ) {
      console.log(m);
    }
  };
  
  
  
  /**
   *  LanguageDefinition
   *  Language definition file handler
   *  Loads language definition files as necessary.
  **/
  var LanguageDefinition = {
     
    _LOADED_LANGS: [],
    _LANG: {},
    
    /** 
     *  Defines a language 
     **/
    define: function( name, definitionObject ) {
      LanguageDefinition._LANG[name] = definitionObject;
    },
    
    /**
     *  loadFor
     *  Asynchronously loads a definition file for the current markup.
     *  Definition files are necessary to use the code editor.
     *
     *  @param  string  markup_name  The markup name you want to load
     *  @return void
    **/
    loadFor: function( markup_name, on_complete ) {
      // attempt to load the definition for this language
      var script_uri = 'js/gollum-editor/langs/' + markup_name + '.js';
      $.ajax({
                url: script_uri, 
                dataType: 'script',
                complete: function(xhr, textStatus) { 
                  if (textStatus == 'success') {
                    LanguageDefinition._LOADED_LANGS.push(markup_name);
                  }
                  if (typeof on_complete == 'function') {
                    on_complete(xhr, textStatus, markup_name);
                  }
                }
            });
    },
    
    
    /**
     *  isLoadedFor
     *  Checks to see if a definition file has been loaded for the 
     *  specified markup language.
     *
     *  @param  string  markup_name   The name of the markup.
     *  @return boolean
    **/
    isLoadedFor: function( markup_name ) {
      if ( LanguageDefinition._LOADED_LANGS.length == 0 ) return false;
      
      for (var i=0; i < LanguageDefinition._LOADED_LANGS.length; i++) {
        if ( LanguageDefinition._LOADED_LANGS[i] == markup_name )
        return true;
      }
      return false;
    }
    
  };
  
  
  /**
   *  EditorHas
   *  Various conditionals to check what features of the Gollum Editor are
   *  active/operational.
  **/
  var EditorHas = {
    
    baseEditorMarkup: function() {
      return ( $('#gollum-editor').length && 
               $('#gollum-editor-body').length );
    },
    
    functionBar: function() {
      return ( ActiveOptions.HasFunctionBar && 
               $('#gollum-editor-function-bar').length );
    }
    
  };
  
  
  /**
   *  FunctionBar
   *
   *  Things the function bar does.
   **/
   var FunctionBar = {
     
      isActive: false,
      
      activate: function() {
        $('#gollum-editor-function-bar a.function-button')
          .click(FunctionBar.evtFunctionButtonClick);
        // show bar as active
        $('#gollum-editor-function-bar').addClass('active');
        this.isActive = true;
      },
      
      evtFunctionButtonClick: function(e) {
        e.preventDefault();
        alert($(this).attr('id'));
      }
      
   };
  
/* })(jQuery); */

jQuery(document).ready(function() {
  $.GollumEditor();
});