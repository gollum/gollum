/**
 *  gollum.editor.js
 *  A jQuery plugin that creates the Gollum Editor.
 *
 *  Usage:
 *  $.GollumEditor(); on DOM ready.
 */
// (function($) {
  
  // Editor options
  var DefaultOptions = {
    MarkupType: 'markdown',
    EditorMode: 'code',
    NewFile: false,
    HasFunctionBar: true,
    Debug: true
  };
  var ActiveOptions = {};
  
  /** 
   *  $.GollumEditor
   *
   *  You don't need to do anything. Just run this on DOM ready.
   */
  $.GollumEditor = function( IncomingOptions ) {
    
    ActiveOptions = $.extend( DefaultOptions, IncomingOptions ); 
    
    debug('GollumEditor loading');
    
    if ( EditorHas.baseEditorMarkup() ) {
      
      if ( EditorHas.titleDisplayed() ) {
        $('#gollum-editor-title-field').addClass('active');
      }
      
      if ( EditorHas.editSummaryMarkup() ) {
        Placeholder.add( $('#gollum-editor-edit-summary input') )
        $('#gollum-editor form[name="gollum-editor"]').submit(function( e ) {
          e.preventDefault();
          Placeholder.clearAll();
          debug('submitting');
          $(this).unbind('submit');
          $(this).submit();
        });
      }
      
      if ( EditorHas.collapsibleInputs() ) {
        $('#gollum-editor .collapsed a.button, ' + 
          '#gollum-editor .expanded a.button').click(function( e ) {
          e.preventDefault();
          $(this).parent().toggleClass('expanded');
          $(this).parent().toggleClass('collapsed');
        });
      }
      
      // Initialize the function bar by loading proper definitions
      if ( EditorHas.functionBar() ) {
        var htmlSetMarkupLang =
          $('#gollum-editor-body').attr('data-markup-lang');
        
        if ( htmlSetMarkupLang ) {
          ActiveOptions.MarkupType = htmlSetMarkupLang;
        }

        if ( !LanguageDefinition.isLoadedFor(ActiveOptions.MarkupType) ) {
          debug('Loading language definition for ' + ActiveOptions.MarkupType);
          LanguageDefinition.loadFor( ActiveOptions.MarkupType, 
            function(data, textStatus) { 
              if ( textStatus != 'success' ) {
                debug('Language definition could not be loaded for markup '
                      + 'type ' + ActiveOptions.MarkupType);
                return;
              }
              // activate the function bar
              debug('Activating function bar');
              FunctionBar.activate();
            } );
        } else {
          // loaded language already
          debug('Activating function bar');
          FunctionBar.activate();
        }
      } 
      // EditorHas.functionBar
    } 
    // EditorHas.baseEditorMarkup
  };
  
  
  
  /**
   *  $.GollumEditor.defineLanguage
   *  Defines a set of language actions that Gollum can use.
   *  Used by the definitions in langs/ to register language definitions.
   */
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
   */
  var debug = function(m) {
    if ( ActiveOptions.Debug 
         && typeof console != 'undefined'
         && typeof console.log == 'function' ) {
      console.log( m );
    }
  };
  
  
  
  /**
   *  LanguageDefinition
   *  Language definition file handler
   *  Loads language definition files as necessary.
   */
  var LanguageDefinition = {
     
    _ACTIVE_LANG: '',
    _LOADED_LANGS: [],
    _LANG: {},
    
    /** 
     *  Defines a language 
     *
     *  @param name string  The name of the language
     *  @param name object  The definition object
     */
    define: function( name, definitionObject ) {
      LanguageDefinition._ACTIVE_LANG = name;
      LanguageDefinition._LOADED_LANGS.push( name );
      LanguageDefinition._LANG[name] = definitionObject;
    },
    
    
    /**
     *  gets a definition object for a specified attribute
     *  
     *  @param  string  attr    The specified attribute.
     *  @param  string  specified_lang  The language to pull a definition for.
     *  @return object if exists, null otherwise
     */
    getDefinitionFor: function( attr, specified_lang ) {
      if ( !specified_lang ) {
        specified_lang = LanguageDefinition._ACTIVE_LANG;
      }
      
      if ( LanguageDefinition.isLoadedFor(specified_lang) &&
           LanguageDefinition._LANG[specified_lang][attr] && 
           typeof LanguageDefinition._LANG[specified_lang][attr] == 'object' ) {
        return LanguageDefinition._LANG[specified_lang][attr];
      }
      
      return null;
    },
    
    
    /**
     *  loadFor
     *  Asynchronously loads a definition file for the current markup.
     *  Definition files are necessary to use the code editor.
     *
     *  @param  string  markup_name  The markup name you want to load
     *  @return void
     */
    loadFor: function( markup_name, on_complete ) {
      // attempt to load the definition for this language
      var script_uri = 'js/gollum-editor/langs/' + markup_name + '.js';
      $.ajax({
                url: script_uri, 
                dataType: 'script',
                complete: function( xhr, textStatus ) { 
                  if ( typeof on_complete == 'function' ) {
                    on_complete( xhr, textStatus );
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
     */
    isLoadedFor: function( markup_name ) {
      if ( LanguageDefinition._LOADED_LANGS.length == 0 ) return false;
      
      for ( var i=0; i < LanguageDefinition._LOADED_LANGS.length; i++ ) {
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
   */
  var EditorHas = {
    
    
    /**
     *  EditorHas.baseEditorMarkup
     *  True if the basic editor form is in place.
     *
     *  @return boolean
     */
    baseEditorMarkup: function() {
      return ( $('#gollum-editor').length && 
               $('#gollum-editor-body').length );
    },
    
    collapsibleInputs: function() {
      return $('#gollum-editor .collapsed, #gollum-editor .expanded').length;
    },
    
    
    /**
     *  EditorHas.functionBar
     *  True if the Function Bar markup exists.
     *
     *  @return boolean
     */
    functionBar: function() {
      return ( ActiveOptions.HasFunctionBar && 
               $('#gollum-editor-function-bar').length );
    },
    
    
    /**
     *  EditorHas.ff4Environment
     *  True if in a Firefox 4.0 Beta environment.
     *
     *  @return boolean
     */
    ff4Environment: function() {
      var ua = new RegExp(/Firefox\/4.0b/);
      return ( ua.test( navigator.userAgent ) );
    },
    
    editSummaryMarkup: function() {
      return ( $('input#gollum-editor-message-field').length > 0 );
    },
    
    titleDisplayed: function() {
      return ( ActiveOptions.NewFile );
    }
    
  };
  
  
  /**
   *  FunctionBar
   *
   *  Things the function bar does.
   */
   var FunctionBar = {
     
      isActive: false,
      
      
      /**
       *  FunctionBar.activate
       *  Activates the function bar, attaching all click events 
       *  and displaying the bar.
       *
       */
      activate: function() {
        // check these out
        $('#gollum-editor-function-bar a.function-button').each(function() {
          if ( LanguageDefinition.getDefinitionFor( $(this).attr('id') ) )
            $(this).click( FunctionBar.evtFunctionButtonClick );
          else 
            $(this).addClass('disabled');
        });

        // show bar as active
        $('#gollum-editor-function-bar').addClass( 'active' );
        FunctionBar.isActive = true;
      },
      
      
      /**
       *  FunctionBar.evtFunctionButtonClick
       *  Event handler for the function buttons. Traps the click and 
       *  executes the proper language action.
       *
       *  @param jQuery.Event jQuery event object.
       */
      evtFunctionButtonClick: function(e) {
        e.preventDefault();
        var def = LanguageDefinition.getDefinitionFor( $(this).attr('id') );
        if ( typeof def == 'object' ) {
          FunctionBar.executeAction( def );
        }
      },
      
      
      /**
       *  FunctionBar.executeAction
       *  Executes a language-specific defined action for a function button.
       *
       */
      executeAction: function( definitionObject ) {
        // get the selected text from the textarea
        var txt = $('#gollum-editor-body').val();
        // hmm, I'm not sure this will work in a textarea
        var selPos = FunctionBar
                      .getFieldSelectionPosition( $('#gollum-editor-body') );
        var selText = FunctionBar.getFieldSelection( $('#gollum-editor-body') );
        var repText = selText;
        var reselect = true;
        
        // execute a replacement function if one exists
        if ( definitionObject.exec && 
             typeof definitionObject.exec == 'function' ) {
          definitionObject.exec ( txt, selText, $('#gollum-editor-body') );
          return;
        }
        
        // execute a search/replace if they exist
        var searchExp = /([^\n]+)/gi;
        if ( definitionObject.search && 
             typeof definitionObject.search == 'object' ) {
          debug('Replacing search Regex');
          searchExp = definitionObject.search;
          debug( searchExp );
        }
        
        // replace text
        if ( definitionObject.replace &&
             typeof definitionObject.replace == 'string' ) {
          debug('Running replacement - using ' + definitionObject.replace);
          repText = repText.replace( searchExp, definitionObject.replace );
        }
        
        // append if necessary
        if ( definitionObject.append && 
             typeof definitionObject.append == 'string' ) {
          if ( repText == selText ) {
            reselect = false;
          }
          repText += definitionObject.append;
        }
        
        if (repText)
          FunctionBar.replaceFieldSelection( $('#gollum-editor-body'), 
                                             repText, reselect );
        
      },
      
      
      /**
       *  getFieldSelectionPosition
       *  Retrieves the selection range for the textarea.
       *
       *  @return object the .start and .end offsets in the string
       */
      getFieldSelectionPosition: function( $field ) {
        if ($field.length) {
          return {
              start: $field[0].selectionStart,
              end: $field[0].selectionEnd
          }
        }
      },
      
      
      /**
       *  getFieldSelection
       *  Returns the currently selected substring of the textarea. 
       *
       *  @param  jQuery  A jQuery object for the textarea.
       *  @return string  Selected string.
       */
      getFieldSelection: function( $field ) {
        var selStr = '';
        var selPos;
        
        if ( $field.length ) {
          selPos = FunctionBar.getFieldSelectionPosition( $field );
          selStr = $field.val().substring( selPos.start, selPos.end );
          debug('Selected: ' + selStr + ' (' + selPos.start + ', ' 
                + selPos.end + ')');
          return selStr;
        }
        return false;
      },
      
      
      /**
       *  replaceFieldSelection
       *  Replaces the currently selected substring of the textarea with 
       *  a new string.
       *
       *  @param  jQuery  A jQuery object for the textarea.
       *  @param  string  The string to replace the current selection with.
       *  @param  boolean Reselect the new text range.
       */
      replaceFieldSelection: function( $field, replaceText, reselect ) {
        var selPos = FunctionBar.getFieldSelectionPosition( $field );
        var fullStr = $field.val();
        var selectNew = true;
        if ( reselect === false) {
          var selectNew = false;
        }
        
        var scrollTop = null;
        if ( $field[0].scrollTop ) {
          scrollTop = $field[0].scrollTop;
        }
        
        $field.val( fullStr.substring(0, selPos.start) + replaceText + 
                    fullStr.substring(selPos.end));
        $field[0].focus();
        
        if ( selectNew && $field[0].setSelectionRange ) {
          $field[0].setSelectionRange( selPos.start, 
                                       selPos.start + replaceText.length ); 
        }
        
        if ( scrollTop ) {
          // this jumps sometimes in FF
          $field[0].scrollTop = scrollTop;
        }
      }
   };
   
   
   /**
    *  $.GollumEditor.Dialog
    *  Used in exec() to display dialogs with dynamic fields.
    *
    */
   $.GollumEditor.Dialog = $.GollumDialog;
   $.GollumEditor.replaceSelection = function( repText ) {
     FunctionBar.replaceFieldSelection( $('#gollum-editor-body'), repText );
   }
   
   
   var Placeholder = {
     
     _PLACEHOLDERS : [],
     
    _p : function( $field ) {
      
       this.fieldObject = $field; 
       this.placeholderText = $field.val();
       var placeholderText = $field.val();
       
       $field.addClass('ph');
       
       $field.blur(function() {
         if ( $(this).val() == '' ) {
           $(this).val( placeholderText );
           $(this).addClass('ph');
         }
       });
       
       $field.focus(function() {
         $(this).removeClass('ph');
         if ( $(this).val() == placeholderText ) {
           $(this).val('');
         } else {
           $(this)[0].select();
         }
       });
       
     },
     
     add : function( $field ) {
       Placeholder._PLACEHOLDERS.push( new Placeholder._p( $field ) );
     },
     
     clearAll: function() {
       for ( var i=0; i < Placeholder._PLACEHOLDERS.length; i++ ) {
         if ( Placeholder._PLACEHOLDERS[i].fieldObject.val() == 
              Placeholder._PLACEHOLDERS[i].placeholderText ) {
           Placeholder._PLACEHOLDERS[i].fieldObject.val('');
         }
       }
     },
     
     exists : function() {
       return ( _PLACEHOLDERS.length );
     }
     
   };
  
// })(jQuery); 
