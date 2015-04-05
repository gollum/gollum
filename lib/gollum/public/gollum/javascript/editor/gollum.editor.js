/**
 *  gollum.editor.js
 *  A jQuery plugin that creates the Gollum Editor.
 *
 *  Usage:
 *  $.GollumEditor(); on DOM ready.
 */
(function($) {

  // Editor options
  var DefaultOptions = {
    MarkupType: 'markdown',
    EditorMode: 'code',
    NewFile: false,
    HasFunctionBar: true,
    Debug: false,
    NoDefinitionsFor: []
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
        $.GollumEditor.Placeholder.add($('#gollum-editor-edit-summary input'));
        $('#gollum-editor form[name="gollum-editor"]').submit(function( e ) {
          e.preventDefault();
          // Do not clear default place holder text
          // Updated home (markdown)
          // $.GollumEditor.Placeholder.clearAll();
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

      if ( EditorHas.previewButton() ) {
        var formAction =
        $('#gollum-editor #gollum-editor-preview').click(function() {
          // make a dummy form, submit to new target window
          // get form fields
          var oldAction = $('#gollum-editor form').attr('action');
          var $form = $($('#gollum-editor form').get(0));
          $form.attr('action', this.href || '/preview');
          $form.attr('target', '_blank');
          var paths = window.location.pathname.split('/');
          $form.attr('page', paths[ paths.length - 1 ] || '')
          $form.submit();


          $form.attr('action', oldAction);
          $form.removeAttr('target');
          return false;
        });
      }

      // Initialize the function bar by loading proper definitions
      if ( EditorHas.functionBar() ) {

        var htmlSetMarkupLang =
          $('#gollum-editor-body').attr('data-markup-lang');

        if ( htmlSetMarkupLang ) {
          ActiveOptions.MarkupType = htmlSetMarkupLang;
        }

        // load language definition
        LanguageDefinition.setActiveLanguage( ActiveOptions.MarkupType );
        if ( EditorHas.formatSelector() ) {
          FormatSelector.init(
            $('#gollum-editor-format-selector select') );
        }

        if ( EditorHas.help() ) {
          $('#gollum-editor-help').hide();
          $('#gollum-editor-help').removeClass('jaws');
        }
      } // EditorHas.functionBar

      if ( EditorHas.dragDropUpload() ) {
        var $editorBody = $('#gollum-editor-body');
        var editorBody = $('#gollum-editor-body')[0];
        editorBody.ondragover = function(e) {
          $editorBody.addClass('dragging');
          return false;
        };
        editorBody.ondragleave = function() {
          $editorBody.removeClass('dragging');
          return false;
        };
        editorBody.ondrop = function(e) {
          debug("dropped file");
          e.preventDefault();
          $editorBody.removeClass('dragging').addClass('uploading');

          var file = e.dataTransfer.files[0],
              formData = new FormData();
          formData.append('upload_dest', uploadDest);
          formData.append('file', file);

          $.ajax({
            url: baseUrl + '/uploadFile',
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            type: 'POST',
            success: function(){
              $editorBody.removeClass('uploading');
              var text = '[[/' + uploadDest + '/' + file.name + ']]';
              var pos = editorBody.selectionStart || 0;
              editorBody.value = editorBody.value.substring(0, pos) + text + editorBody.value.substring(pos);
              editorBody.selectionStart = pos + text.length;
              editorBody.selectionEnd = pos + text.length;
            },
            error: function(r, textStatus) {
              alert('Error uploading file: ' + textStatus);
              $editorBody.removeClass('uploading');
            }
          });

          return false;
        };
      } // EditorHas.dragDropUpload
    } // EditorHas.baseEditorMarkup
  };



  /**
   *  $.GollumEditor.defineLanguage
   *  Defines a set of language actions that Gollum can use.
   *  Used by the definitions in langs/ to register language definitions.
   */
  $.GollumEditor.defineLanguage = function( language_name, languageObject ) {
    if ( typeof languageObject == 'object' ) {
      LanguageDefinition.define( language_name, languageObject );
    } else {
      debug('GollumEditor.defineLanguage: definition for ' + language_name +
            ' is not an object');
    }
  };


  /**
   *  debug
   *  Prints debug information to console.log if debug output is enabled.
   *
   *  @param  mixed  Whatever you want to dump to console.log
   *  @return void
   */
  var debug = function(m) {
    if ( ActiveOptions.Debug &&
         typeof console != 'undefined' ) {
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
      if ( typeof $.GollumEditor.WikiLanguage == 'object' ) {
        var definition = {};
        $.extend(definition, $.GollumEditor.WikiLanguage, definitionObject);
        LanguageDefinition._LANG[name] = definition;
      } else {
        LanguageDefinition._LANG[name] = definitionObject;
      }
    },

    getActiveLanguage: function() {
      return LanguageDefinition._ACTIVE_LANG;
    },

    setActiveLanguage: function( name ) {
      // On first load _ACTIVE_LANG.length is 0 and evtChangeFormat isn't called.
      if ( LanguageDefinition._ACTIVE_LANG != null && LanguageDefinition._ACTIVE_LANG.length <= 0 ) {
        FormatSelector.updateCommitMessage( name );
      }

      if(LanguageDefinition.getHookFunctionFor("deactivate")) {
        LanguageDefinition.getHookFunctionFor("deactivate")();
      }
      if ( !LanguageDefinition.isLoadedFor(name) ) {
        LanguageDefinition._ACTIVE_LANG = null;
        LanguageDefinition.loadFor( name, function(x, t) {
          if ( t != 'success' ) {
            debug('Failed to load language definition for ' + name);
            // well, fake it and turn everything off for this one
            LanguageDefinition.define( name, {} );
          }

          // update features that rely on the language definition
          if ( EditorHas.functionBar() ) {
            FunctionBar.refresh();
          }

          if ( LanguageDefinition.isValid() && EditorHas.formatSelector() ) {
            FormatSelector.updateSelected();
          }

          if(LanguageDefinition.getHookFunctionFor("activate")) {
            LanguageDefinition.getHookFunctionFor("activate")();
          }

          function hotkey( e, cmd ) {
            e.preventDefault();

            var def = LanguageDefinition.getDefinitionFor( cmd );
            if ( typeof def == 'object' ) {
              FunctionBar.executeAction( def );
            }
            // Prevent bubbling of hotkey.
            return false;
          }

          Mousetrap.bind(['command+1', 'ctrl+1'], function( e ){ hotkey( e, 'function-h1' ); });
          Mousetrap.bind(['command+2', 'ctrl+2'], function( e ){ hotkey( e, 'function-h2' ); });
          Mousetrap.bind(['command+3', 'ctrl+3'], function( e ){ hotkey( e, 'function-h3' ); });
          Mousetrap.bind(['command+b', 'ctrl+b'], function( e ){ hotkey( e, 'function-bold' ); });
          Mousetrap.bind(['command+i', 'ctrl+i'], function( e ){ hotkey( e, 'function-italic' ); });
          Mousetrap.bind(['command+s', 'ctrl+s'], function( e ){
            e.preventDefault();
            $("#gollum-editor-submit").trigger("click");
            return false;
          });

        } );
      } else {
        LanguageDefinition._ACTIVE_LANG = name;
        FunctionBar.refresh();

        if(LanguageDefinition.getHookFunctionFor("activate")) {
          LanguageDefinition.getHookFunctionFor("activate")();
        }
      }
    },

    getHookFunctionFor: function(attr, specified_lang) {
      if ( !specified_lang ) {
        specified_lang = LanguageDefinition._ACTIVE_LANG;
      }

      if ( LanguageDefinition.isLoadedFor(specified_lang) &&
           LanguageDefinition._LANG[specified_lang][attr] &&
           typeof LanguageDefinition._LANG[specified_lang][attr] == 'function' ) {
        return LanguageDefinition._LANG[specified_lang][attr];
      }

      return null;
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
      // Keep us from hitting 404s on our site, check the definition blacklist
      if ( ActiveOptions.NoDefinitionsFor.length ) {
        for ( var i=0; i < ActiveOptions.NoDefinitionsFor.length; i++ ) {
          if ( markup_name == ActiveOptions.NoDefinitionsFor[i] ) {
            // we don't have this. get out.
            if ( typeof on_complete == 'function' ) {
              on_complete( null, 'error' );
              return;
            }
          }
        }
      }

      // attempt to load the definition for this language
      var script_uri = baseUrl + '/javascript/editor/langs/' + markup_name + '.js';
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
      if ( LanguageDefinition._LOADED_LANGS.length === 0 ) {
        return false;
      }

      for ( var i=0; i < LanguageDefinition._LOADED_LANGS.length; i++ ) {
        if ( LanguageDefinition._LOADED_LANGS[i] == markup_name ) {
          return true;
        }
      }
      return false;
    },

    isValid: function() {
      return ( LanguageDefinition._ACTIVE_LANG &&
               typeof LanguageDefinition._LANG[LanguageDefinition._ACTIVE_LANG] ==
               'object' );
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


    /**
     *  EditorHas.collapsibleInputs
     *  True if the editor contains collapsible inputs for things like the
     *  sidebar or footer, false otherwise.
     *
     *  @return boolean
     */
    collapsibleInputs: function() {
      return $('#gollum-editor .collapsed, #gollum-editor .expanded').length;
    },


    /**
     *  EditorHas.formatSelector
     *  True if the editor has a format selector (for switching between
     *  language types), false otherwise.
     *
     *  @return boolean
     */
    formatSelector: function() {
      return $('#gollum-editor-format-selector select').length;
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


    /**
     *  EditorHas.editSummaryMarkup
     *  True if the editor has a summary field (Gollum's commit message),
     *  false otherwise.
     *
     *  @return boolean
     */
    editSummaryMarkup: function() {
      return ( $('input#gollum-editor-message-field').length > 0 );
    },


    /**
     *  EditorHas.help
     *  True if the editor contains the inline help sector, false otherwise.
     *
     *  @return boolean
     */
    help: function() {
      return ( $('#gollum-editor #gollum-editor-help').length &&
               $('#gollum-editor #function-help').length );
    },


    /**
     *  EditorHas.previewButton
     *  True if the editor has a preview button, false otherwise.
     *
     *  @return boolean
     */
    previewButton: function() {
      return ( $('#gollum-editor #gollum-editor-preview').length );
    },


    /**
     *  EditorHas.titleDisplayed
     *  True if the editor is displaying a title field, false otherwise.
     *
     *  @return boolean
     */
    titleDisplayed: function() {
      return ( ActiveOptions.NewFile );
    },


    /**
     *  EditorHas.dragDropUpload
     *  True if the editor is supports drag and drop file uploads, false otherwise.
     *
     *  @return boolean
     */
    dragDropUpload: function() {
      return $('#gollum-editor.uploads-allowed').length;
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
        debug('Activating function bar');

        // check these out
        $('#gollum-editor-function-bar a.function-button').each(function() {
          if ( LanguageDefinition.getDefinitionFor( $(this).attr('id') ) ) {
            $(this).click( FunctionBar.evtFunctionButtonClick );
            $(this).removeClass('disabled');
          }
          else if ( $(this).attr('id') != 'function-help' ) {
            $(this).addClass('disabled');
          }
        });

        // show bar as active
        $('#gollum-editor-function-bar').addClass( 'active' );
        FunctionBar.isActive = true;
      },


      deactivate: function() {
        $('#gollum-editor-function-bar a.function-button').unbind('click');
        $('#gollum-editor-function-bar').removeClass( 'active' );
        FunctionBar.isActive = false;
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
        var cursor = null;

        // execute a replacement function if one exists
        if ( definitionObject.exec &&
             typeof definitionObject.exec == 'function' ) {
          definitionObject.exec( txt, selText, $('#gollum-editor-body') );
          return;
        }

        // execute a search/replace if they exist
        var searchExp = /([^\n]+)/gi;
        if ( definitionObject.search &&
             typeof definitionObject.search == 'object' ) {
          debug('Replacing search Regex');
          searchExp = null;
          searchExp = new RegExp ( definitionObject.search );
          debug( searchExp );
        }
        debug('repText is ' + '"' + repText + '"');
        // replace text
        if ( definitionObject.replace &&
             typeof definitionObject.replace == 'string' ) {
          debug('Running replacement - using ' + definitionObject.replace);
          var rt = definitionObject.replace;

          repText = escape( repText );
          repText = repText.replace( searchExp, rt );
          // remove backreferences
          repText = repText.replace( /\$[\d]/g, '' );
          repText = unescape( repText );

          if ( repText === '' ) {
            debug('Search string is empty');

            // find position of $1 - this is where we will place the cursor
            cursor = rt.indexOf('$1');

            // we have an empty string, so just remove backreferences
            repText = rt.replace( /\$[\d]/g, '' );

            // if the position of $1 doesn't exist, stick the cursor in
            // the middle
            if ( cursor == -1 ) {
              cursor = Math.floor( rt.length / 2 );
            }
          }
        }

        // append if necessary
        if ( definitionObject.append &&
             typeof definitionObject.append == 'string' ) {
          if ( repText == selText ) {
            reselect = false;
          }
          repText += definitionObject.append;
        }

        if ( repText ) {
          FunctionBar.replaceFieldSelection( $('#gollum-editor-body'),
                                             repText, reselect, cursor );
        }

      },


      /**
       *  getFieldSelectionPosition
       *  Retrieves the selection range for the textarea.
       *
       *  @return object the .start and .end offsets in the string
       */
      getFieldSelectionPosition: function( $field ) {
        if ($field.length) {
          var start = 0, end = 0;
          var el = $field.get(0);

          if (typeof el.selectionStart == "number" &&
              typeof el.selectionEnd == "number") {
            start = el.selectionStart;
            end = el.selectionEnd;
          } else {
            var range = document.selection.createRange();
            var stored_range = range.duplicate();
            stored_range.moveToElementText( el );
            stored_range.setEndPoint( 'EndToEnd', range );
            start = stored_range.text.length - range.text.length;
            end = start + range.text.length;

            // so, uh, we're close, but we need to search for line breaks and
            // adjust the start/end points accordingly since IE counts them as
            // 2 characters in TextRange.
            var s = start;
            var lb = 0;
            var i;
            debug('IE: start position is currently ' + s);
            for ( i=0; i < s; i++ ) {
              if ( el.value.charAt(i).match(/\r/) ) {
                ++lb;
              }
            }

            if ( lb ) {
              debug('IE start: compensating for ' + lb + ' line breaks');
              start = start - lb;
              lb = 0;
            }

            var e = end;
            for ( i=0; i < e; i++ ) {
              if ( el.value.charAt(i).match(/\r/) ) {
                ++lb;
              }
            }

            if ( lb ) {
              debug('IE end: compensating for ' + lb + ' line breaks');
              end = end - lb;
            }
          }

          return {
              start: start,
              end: end
          };
        } // end if ($field.length)
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
          debug('Selected: ' + selStr + ' (' + selPos.start + ', ' +
                selPos.end + ')');
          return selStr;
        }
        return false;
      },


      isShown: function() {
        return ($('#gollum-editor-function-bar').is(':visible'));
      },

      refresh: function() {
        if ( EditorHas.functionBar() ) {
          debug('Refreshing function bar');
          if ( LanguageDefinition.isValid() ) {
            $('#gollum-editor-function-bar a.function-button').unbind('click');
            FunctionBar.activate();
            if ( Help ) {
              Help.setActiveHelp( LanguageDefinition.getActiveLanguage() );
            }
          } else {
            debug('Language definition is invalid.');
            if ( FunctionBar.isShown() ) {
              // deactivate the function bar; it's not gonna work now
              FunctionBar.deactivate();
            }
            if ( Help.isShown() ) {
              Help.hide();
            }
          }
        }
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
      replaceFieldSelection: function( $field, replaceText, reselect, cursorOffset ) {
        var selPos = FunctionBar.getFieldSelectionPosition( $field );
        var fullStr = $field.val();
        var selectNew = true;
        if ( reselect === false) {
          selectNew = false;
        }

        var scrollTop = null;
        if ( $field[0].scrollTop ) {
          scrollTop = $field[0].scrollTop;
        }

        $field.val( fullStr.substring(0, selPos.start) + replaceText +
                    fullStr.substring(selPos.end) );
        $field[0].focus();

        if ( selectNew ) {
          if ( $field[0].setSelectionRange ) {
            if ( cursorOffset ) {
              $field[0].setSelectionRange(
                                            selPos.start + cursorOffset,
                                            selPos.start + cursorOffset
               );
            } else {
              $field[0].setSelectionRange( selPos.start,
                                           selPos.start + replaceText.length );
            }
          } else if ( $field[0].createTextRange ) {
            var range = $field[0].createTextRange();
            range.collapse( true );
            if ( cursorOffset ) {
              range.moveEnd( selPos.start + cursorOffset );
              range.moveStart( selPos.start + cursorOffset );
            } else {
              range.moveEnd( 'character', selPos.start + replaceText.length );
              range.moveStart( 'character', selPos.start );
            }
            range.select();
          }
        }

        if ( scrollTop ) {
          // this jumps sometimes in FF
          $field[0].scrollTop = scrollTop;
        }
      }
   };



   /**
    *  FormatSelector
    *
    *  Functions relating to the format selector (if it exists)
    */
   var FormatSelector = {

     $_SELECTOR: null,

     /**
      *  FormatSelector.evtChangeFormat
      *  Event handler for when a format has been changed by the format
      *  selector. Will automatically load a new language definition
      *  via JS if necessary.
      *
      *  @return void
      */
     evtChangeFormat: function( e ) {
       var newMarkup = $(this).val();
       FormatSelector.updateCommitMessage( newMarkup );
       LanguageDefinition.setActiveLanguage( newMarkup );
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
       if ( FormatSelector.$_SELECTOR &&
            typeof FormatSelector.$_SELECTOR == 'object' ) {
         FormatSelector.$_SELECTOR.unbind( 'change' );
       }

       FormatSelector.$_SELECTOR = $sel;

       // set format selector to the current language
       FormatSelector.updateSelected();
       FormatSelector.$_SELECTOR.change( FormatSelector.evtChangeFormat );
     },


     /**
      * FormatSelector.update
      */
    updateSelected: function() {
       var currentLang = LanguageDefinition.getActiveLanguage();
       FormatSelector.$_SELECTOR.val( currentLang );
    }

   };



   /**
    *  Help
    *
    *  Functions that manage the display and loading of inline help files.
    */
  var Help = {

    _ACTIVE_HELP: '',
    _LOADED_HELP_LANGS: [],
    _HELP: {},

    /**
     *  Help.define
     *
     *  Defines a new help context and enables the help function if it
     *  exists in the Gollum Function Bar.
     *
     *  @param string name   The name you're giving to this help context.
     *                       Generally, this should match the language name.
     *  @param object definitionObject The definition object being loaded from a
     *                                 language / help definition file.
     *  @return void
     */
    define: function( name, definitionObject ) {
      if ( Help.isValidHelpFormat( definitionObject ) ) {
        debug('help is a valid format');

        Help._ACTIVE_HELP_LANG = name;
        Help._LOADED_HELP_LANGS.push( name );
        Help._HELP[name] = definitionObject;

        if ( $("#function-help").length ) {
          if ( $('#function-help').hasClass('disabled') ) {
            $('#function-help').removeClass('disabled');
          }
          $('#function-help').unbind('click');
          $('#function-help').click( Help.evtHelpButtonClick );

          // generate help menus
          Help.generateHelpMenuFor( name );

          if ( $('#gollum-editor-help').length &&
               typeof $('#gollum-editor-help').attr('data-autodisplay') !== 'undefined' &&
               $('#gollum-editor-help').attr('data-autodisplay') === 'true' ) {
            Help.show();
          }
        }
      } else {
        if ( $('#function-help').length ) {
          $('#function-help').addClass('disabled');
        }
      }
    },

    /**
     *  Help.generateHelpMenuFor
     *  Generates the markup for the main help menu given a context name.
     *
     *  @param string  name  The context name.
     *  @return void
     */
    generateHelpMenuFor: function( name ) {
      if ( !Help._HELP[name] ) {
        debug('Help is not defined for ' + name.toString());
        return false;
      }
      var helpData = Help._HELP[name];

      // clear this shiz out
      $('#gollum-editor-help-parent').html('');
      $('#gollum-editor-help-list').html('');
      $('#gollum-editor-help-content').html('');

      // go go inefficient algorithm
      for ( var i=0; i < helpData.length; i++ ) {
        if ( typeof helpData[i] != 'object' ) {
          break;
        }

        var $newLi = $('<li><a href="#" rel="' + i + '">' +
                       helpData[i].menuName + '</a></li>');
        $('#gollum-editor-help-parent').append( $newLi );
        if ( i === 0 ) {
          // select on first run
          $newLi.children('a').addClass('selected');
        }
        $newLi.children('a').click( Help.evtParentMenuClick );
      }

      // generate parent submenu on first run
      Help.generateSubMenu( helpData[0], 0 );
      $($('#gollum-editor-help-list li a').get(0)).click();

    },

    /**
     *  Help.generateSubMenu
     *  Generates the markup for the inline help sub-menu given the data
     *  object for the submenu and the array index to start at.
     *
     *  @param object subData The data for the sub-menu.
     *  @param integer index  The index clicked on (parent menu index).
     *  @return void
     */
    generateSubMenu: function( subData, index ) {
      $('#gollum-editor-help-list').html('');
      $('#gollum-editor-help-content').html('');
      for ( var i=0; i < subData.content.length; i++ ) {
        if ( typeof subData.content[i] != 'object' ) {
          break;
        }

        var $subLi = $('<li><a href="#" rel="' + index + ':' + i + '">' +
                       subData.content[i].menuName + '</a></li>');


        $('#gollum-editor-help-list').append( $subLi );
        $subLi.children('a').click( Help.evtSubMenuClick );
      }
    },

    hide: function() {
      if ( $.browser.msie ) {
        $('#gollum-editor-help').css('display', 'none');
      } else {
        $('#gollum-editor-help').animate({
          opacity: 0
        }, 200, function() {
          $('#gollum-editor-help')
            .animate({ height: 'hide' }, 200);
        });
      }
    },

    show: function() {
      if ( $.browser.msie ) {
        // bypass effects for internet explorer, since it does weird crap
        // to text antialiasing with opacity animations
        $('#gollum-editor-help').css('display', 'block');
      } else {
        $('#gollum-editor-help').animate({
          height: 'show'
        }, 200, function() {
          $('#gollum-editor-help')
            .animate({ opacity: 1 }, 300);
        });
      }
    },

    /**
     *  Help.showHelpFor
     *  Displays the actual help content given the two menu indexes, which are
     *  rendered in the rel="" attributes of the help menus
     *
     *  @param integer index1  parent index
     *  @param integer index2  submenu index
     *  @return void
     */
    showHelpFor: function( index1, index2 ) {
      var html =
        Help._HELP[Help._ACTIVE_HELP_LANG][index1].content[index2].data;
      $('#gollum-editor-help-content').html(html);
    },

    /**
     *  Help.isLoadedFor
     *  Returns true if help is loaded for a specific markup language,
     *  false otherwise.
     *
     *  @param string name   The name of the markup language.
     *  @return boolean
     */
    isLoadedFor: function( name ) {
      for ( var i=0; i < Help._LOADED_HELP_LANGS.length; i++ ) {
        if ( name == Help._LOADED_HELP_LANGS[i] ) {
          return true;
        }
      }
      return false;
    },

    isShown: function() {
      return ($('#gollum-editor-help').is(':visible'));
    },

    /**
     *  Help.isValidHelpFormat
     *  Does a quick check to make sure that the help definition isn't in a
     *  completely messed-up format.
     *
     *  @param object (Array) helpArr  The help definition array.
     *  @return boolean
     */
    isValidHelpFormat: function( helpArr ) {
      return ( typeof helpArr == 'object' &&
               helpArr.length &&
               typeof helpArr[0].menuName == 'string' &&
               typeof helpArr[0].content == 'object' &&
               helpArr[0].content.length );
    },

    /**
     *  Help.setActiveHelp
     *  Sets the active help definition to the one defined in the argument,
     *  re-rendering the help menu to match the new definition.
     *
     *  @param string  name  The name of the help definition.
     *  @return void
     */
    setActiveHelp: function( name ) {
      if ( !Help.isLoadedFor( name ) ) {
        if ( $('#function-help').length ) {
          $('#function-help').addClass('disabled');
        }
        if ( Help.isShown() ) {
          Help.hide();
        }
      } else {
        Help._ACTIVE_HELP_LANG = name;
        if ( $("#function-help").length ) {
          if ( $('#function-help').hasClass('disabled') ) {
            $('#function-help').removeClass('disabled');
          }
          $('#function-help').unbind('click');
          $('#function-help').click( Help.evtHelpButtonClick );
          Help.generateHelpMenuFor( name );
        }
      }
    },

    /**
     *  Help.evtHelpButtonClick
     *  Event handler for clicking the help button in the function bar.
     *
     *  @param jQuery.Event e  The jQuery event object.
     *  @return void
     */
    evtHelpButtonClick: function( e ) {
      e.preventDefault();
      if ( Help.isShown() ) {
        // turn off autodisplay if it's on
        if ( $('#gollum-editor-help').length &&
             $('#gollum-editor-help').attr('data-autodisplay') !== 'undefined' &&
             $('#gollum-editor-help').attr('data-autodisplay') === 'true' ) {
          $.post('/wiki/help?_method=delete');
          $('#gollum-editor-help').attr('data-autodisplay', '');
        }
        Help.hide(); }
      else { Help.show(); }
    },

    /**
     *  Help.evtParentMenuClick
     *  Event handler for clicking on an item in the parent menu. Automatically
     *  renders the submenu for the parent menu as well as the first result for
     *  the actual plain text.
     *
     *  @param jQuery.Event e  The jQuery event object.
     *  @return void
     */
    evtParentMenuClick: function( e ) {
      e.preventDefault();
      // short circuit if we've selected this already
      if ( $(this).hasClass('selected') ) { return; }

      // populate from help data for this
      var helpIndex = $(this).attr('rel');
      var subData = Help._HELP[Help._ACTIVE_HELP_LANG][helpIndex];

      $('#gollum-editor-help-parent li a').removeClass('selected');
      $(this).addClass('selected');
      Help.generateSubMenu( subData, helpIndex );
      $($('#gollum-editor-help-list li a').get(0)).click();
    },

    /**
     *  Help.evtSubMenuClick
     *  Event handler for clicking an item in a help submenu. Renders the
     *  appropriate text for the submenu link.
     *
     *  @param jQuery.Event e  The jQuery event object.
     *  @return void
     */
    evtSubMenuClick: function( e ) {
      e.preventDefault();
      if ( $(this).hasClass('selected') ) { return; }

      // split index rel data
      var rawIndex = $(this).attr('rel').split(':');
      $('#gollum-editor-help-list li a').removeClass('selected');
      $(this).addClass('selected');
      Help.showHelpFor( rawIndex[0], rawIndex[1] );
    }
  };

  // Publicly-accessible function to Help.define
  $.GollumEditor.defineHelp = Help.define;

  // Dialog exists as its own thing now
  $.GollumEditor.Dialog = $.GollumDialog;
  $.GollumEditor.replaceSelection = function( repText ) {
    FunctionBar.replaceFieldSelection( $('#gollum-editor-body'), repText );
  };

  // Placeholder exists as its own thing now
  $.GollumEditor.Placeholder = $.GollumPlaceholder;

})(jQuery);
