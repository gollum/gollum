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
  var autoSaveTimer = null;
  var storageKey = 'gollum_autorecover_' + window.location;

  function isRTL(s){           
    var ltrChars    = 'A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u02B8\u0300-\u0590\u0800-\u1FFF'+'\u2C00-\uFB1C\uFDFE-\uFE6F\uFEFD-\uFFFF',
        rtlChars    = '\u0591-\u07FF\uFB1D-\uFDFD\uFE70-\uFEFC',
        rtlDirCheck = new RegExp('^[^'+ltrChars+']*['+rtlChars+']');

    return rtlDirCheck.test(s);
  };

  function switchRtl(b){
    window.ace_editor.session.$bidiHandler.$isRtl = b;
    window.ace_editor.session.$bidiHandler.updateBidiMap();
    window.ace_editor.renderer.updateFull();
  }

  function autoSaveHandler() {
    // Autosave
    if (autoSaveTimer) {
      // Reset the timer because we just changed the text
      clearTimeout(autoSaveTimer);
    }

    $('#gollum-saved-msg').text('Saving...');

    // Wait 2 seconds, then actually save the text to local storage
    autoSaveTimer = setTimeout(function() {
      localStorage.setItem(storageKey, window.ace_editor.getSession().getValue());
      // Save any subpage editor text that might exist
      $('#gollum-editor-header, #gollum-editor-footer, #gollum-editor-sidebar').each(function(_, el) {
        var spStorageKey = storageKey + el.id.replace('gollum-editor-', '_');
        localStorage.setItem(spStorageKey, el.value);
      });
      $('#gollum-saved-msg').text('Saved recovery text');
    }, 2000);
  }

  function setEditorKeyboardHandler(mode) {
    var editor = window.ace_editor;
    var storage = window.localStorage;
    storage.setItem('gollum-kbm', mode)
    if (mode == "default") {
      editor.setKeyboardHandler();
    } else if (mode == "vim" || mode == "emacs") {
      editor.setKeyboardHandler("ace/keyboard/" + mode);
    } else {
      editor.setKeyboardHandler();
    }
    editor.focus();
  }

  /**
   *  $.GollumEditor
   *
   *  You don't need to do anything. Just run this on DOM ready.
   */
  $.GollumEditor = function( IncomingOptions ) {
    ActiveOptions = $.extend( DefaultOptions, IncomingOptions );

    $('textarea[id="gollum-editor-body"]').each(function () {
      var textarea = $(this);
      var mode = textarea.attr("data-markup-lang") ? textarea.attr("data-markup-lang") : "markdown"
      var editDiv = $('<div>', {
        position: 'absolute',
        height: textarea.height(),
        'class': textarea.attr('class'),
        'id': 'gollum-editor-body-ace'
      }).insertAfter(textarea);
      textarea.css('display', 'none');

      // NOTE: This requires the page to have only one 'gollum-editor-body'.
      var editor = ace.edit(editDiv[0], {rtlText: true});
      window.ace_editor = editor;

      // Check to see if we have any autosaved text and show a message to
      // restore it if present.
      var savedText = localStorage.getItem(storageKey);

      if (savedText) {
        $('#gollum-autorecover-button').click(function(e) {
            editor.getSession().setValue(savedText);
            // Restore subpage editor values too, if they exist
            ['header', 'footer', 'sidebar'].forEach(function(i) {
              var sbSavedText = localStorage.getItem(storageKey + '_' + i);
              if (sbSavedText) {
                $('#gollum-editor-' + i).val(sbSavedText);
              }
            });
            $('#gollum-autorecover-msg')[0].hidden = true;
            e.preventDefault();
        });
        $('#gollum-autorecover-msg')[0].hidden = false;
      }
      
      // Check for user last keybind and ensure ui is correct 
      var storage = window.localStorage;
      var userDefaultKeybind = storage.getItem('gollum-kbm'); 
      if (userDefaultKeybind) {
         default_keybinding = userDefaultKeybind;
      }
      var keybinding = document.getElementById('keybinding')
      for (var i = 0; i < keybinding.options.length; ++i) {
        if (keybinding.options[i].text === default_keybinding) {
            keybinding.options[i].selected = true;
        }
      }
        
      editor.setTheme("ace/theme/tomorrow");
      setEditorKeyboardHandler(default_keybinding);
      editor.renderer.setShowGutter(false);
      editor.getSession().setUseWrapMode(true);
      editor.getSession().setValue(textarea.val());
      editor.getSession().setMode($.getEditorMode(mode));

      editor.getSession().on('change', function(){
        textarea.val(editor.getSession().getValue());
        autoSaveHandler();
      });

      // Autosave for the header, footer and sidebar
      $('#gollum-editor-header, #gollum-editor-footer, #gollum-editor-sidebar')
        .on('change keyup paste', autoSaveHandler);

      if (isRTL(editor.getSession().getLine(0))) {
        switchRtl(true);
      }

      editor.commands.addCommand({
        name: "showKeyboardShortcuts",
        bindKey: {win: "Ctrl-Alt-h", mac: "Command-Alt-h"},
        exec: function(editor) {
            ace.config.loadModule("ace/ext/keybinding_menu", function(module) {
                module.init(editor);
                editor.showKeyboardShortcuts();
            });
        }
      });

      if ( ActiveOptions.commands ) {
        $.each(ActiveOptions.commands, function ( index, cmd ) {
          editor.commands.addCommand(cmd);
        });
      }
    });

      
    $("#gollum-editor-body-ace").resize(function(){
      window.ace_editor.resize();
    });

    $("#wiki_format").change(function() {
      var mode = $(this).val();
      var editor = window.ace_editor;
      window.ace_editor.getSession().setMode($.getEditorMode(mode));
      FormatSelector.updateCommitMessage(mode);
      editor.focus();
    });

    $("#keybinding").change(function() {
      var mode = $(this).val();
      setEditorKeyboardHandler(mode)
    });

    // Remove any autosaved text when we hit save or cancel
    $("#gollum-editor-submit, #gollum-editor-cancel").click(function() {
      var storageKey = 'gollum_autorecover_' + window.location;
      localStorage.removeItem(storageKey);
      // Clear subpage editor values too, if they exist
      ['header', 'footer', 'sidebar'].forEach(function(i) {
        localStorage.removeItem(storageKey + '_' + i);
      });
    });

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
        $('#gollum-editor .collapsed button.collapsable, ' +
          '#gollum-editor .expanded button.collapsable').click(function( e ) {
          e.preventDefault();
          $(this).parent().toggleClass('expanded');
          $(this).parent().toggleClass('collapsed');

          buttons = $(this).parent().children("button");
          hidden_button = buttons.filter(':hidden')[0];
          shown_button  = buttons.not(':hidden')[0];
          hidden_button.hidden = false;
          shown_button.hidden = true;
        });
      }

      if ( EditorHas.previewButton() ) {
        var formAction =
        $('#gollum-editor #gollum-editor-preview').click(function() {
          // make a dummy form, submit to new target window
          // get form fields
          var oldAction = $('#gollum-editor form').attr('action');
          var $form = $($('#gollum-editor form').get(0));
          $form.attr('action', this.href || routePath('preview'));
          $form.attr('target', '_blank');
          var paths = window.location.pathname.split('/');
          $form.attr('page', decodeURIComponent(paths[ paths.length - 1 ]) || '')
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
            $('#wiki_format') );
        }

        if ( EditorHas.dir() ) {
          $('#function-text-direction').click(function( e ) {
            e.preventDefault();
            switchRtl(!window.ace_editor.session.$bidiHandler.$isRtl);
          });
        }

        if ( EditorHas.help() ) {
          $('#gollum-editor-help').hide();
          $('#gollum-editor-help').removeClass('jaws');
        }
      } // EditorHas.functionBar

      if (ActiveOptions['section'] && $.markupSupportsEditableSections ( ActiveOptions.MarkupType )) {
        var sectionLine = $.findSection(ActiveOptions['section'], LanguageDefinition.getDefinitionFor('gollum-helpers'));
        if (sectionLine) {
          window.ace_editor.gotoLine(sectionLine+1, 0, animate=false); 
          window.ace_editor.scrollToLine(sectionLine, center = false, animate = false);
          window.ace_editor.focus();
        }
      }

      if ( EditorHas.dragDropUpload() ) {
        var $editorBody = $('#gollum-editor-body-ace');
        var editorBody = $('#gollum-editor-body-ace')[0];
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
          formData.append('file', file);
          
          $.ajax({
            url: routePath('upload_file'),
            data: formData,
            cache: false,
            contentType: false,
            processData: false,
            type: 'POST',
            success: function(){
              $editorBody.removeClass('uploading');
              var ext = file.name.split('.').pop().toLowerCase()
              var image_ext = ['jpg', 'jpeg', 'tif', 'tiff', 'png', 'gif', 'svg', 'bmp']
              // Link directly to image files
              uploadDest = uploadDest.replace(/%20/g, ' ');
              if ((image_ext.indexOf(ext) > -1)) {
                var text = '[[/' + uploadDest + '/' + file.name + ']]';
              } else {
                // Add file name to tag for non-image files, to avoid broken image thumbnail
                var text = '[[' + file.name + '|/' + uploadDest + '/' + file.name + ']]';
              }
              window.ace_editor.insert(text);
            },
            error: function(data, textStatus, errorThrown) {
              if (data.status == 409) {
                alert('This file already exists.');
              } else {
                alert('Error uploading file: ' + textStatus + ' ' + errorThrown);    
              }
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

      } else {
        LanguageDefinition._ACTIVE_LANG = name;
        FunctionBar.refresh();

        if(LanguageDefinition.getHookFunctionFor("activate")) {
          LanguageDefinition.getHookFunctionFor("activate")();
        }
      }

      function hotkey( cmd ) {
        return function () {
          var def = LanguageDefinition.getDefinitionFor( cmd );
          if ( typeof def == 'object' ) {
            FunctionBar.executeAction( def );
          }
        };
      }

      window.ace_editor.commands.addCommand({
        name: "header-1",
        bindKey: {win: "Ctrl-1", mac: "Command-1"},
        exec: hotkey('function-h1')
      });
      window.ace_editor.commands.addCommand({
        name: "header-2",
        bindKey: {win: "Ctrl-2", mac: "Command-2"},
        exec: hotkey('function-h2')
      });
      window.ace_editor.commands.addCommand({
        name: "header-3",
        bindKey: {win: "Ctrl-3", mac: "Command-3"},
        exec: hotkey('function-h3')
      });
      window.ace_editor.commands.addCommand({
        name: "bold-text",
        bindKey: {win: "Ctrl-b", mac: "Command-b"},
        exec: hotkey('function-bold')
      });
      window.ace_editor.commands.addCommand({
        name: "italic-text",
        bindKey: {win: "Ctrl-i", mac: "Command-i"},
        exec: hotkey('function-italic')
      });
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
      return $('#wiki_format').length;
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
     *  EditorHas.dir
     *  True if the editor contains the inline text direction button.
     *
     *  @return boolean
     */
    dir: function() {
      return ($('#gollum-editor #function-text-direction').length );
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
        $('#gollum-editor-function-bar button.function-button').each(function() {
          if ( LanguageDefinition.getDefinitionFor( $(this).attr('id') ) ) {
            $(this).click( FunctionBar.evtFunctionButtonClick );
            $(this).attr('disabled', false);
          }
          else if ( !['function-help', 'function-text-direction'].includes( $(this).attr('id') ) ) {
            $(this).attr('disabled', true);
          }
        });

        // show bar as active
        $('#gollum-editor-function-bar').addClass( 'active' );
        FunctionBar.isActive = true;
      },


      deactivate: function() {
        // When we switch markup language, unbind all buttons *except* for the text direction (LTR/RTL) switching button
        $('#gollum-editor-function-bar button.function-button').not('#function-text-direction').unbind('click');
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
        var editor = window.ace_editor;
        var txt = editor.getValue();
        var breakBefore = false;
        var breakAfter = false;
        var selRange = editor.getSelectionRange();
        var selText = editor.getSelectedText();
        var selTextLength = selText.length;
        var wholeLine = false;
        if (selText == '' ) {
          if (definitionObject.whole_line && definitionObject.whole_line == true) {
            wholeLine = true;
            var line = selRange.start.row;
            selText = editor.session.getLine(line);
            var Range = ace.require('ace/range').Range;
            selRange = new Range(line, 0, line, selText.length);
          } else if (definitionObject.break_line && definitionObject.break_line == true) {
            breakBefore = true;
            breakAfter = true;
          }
        } else if (definitionObject.break_line && definitionObject.break_line == true) {
          breakBefore = true;
          breakAfter  = true;
        }

        var repText = selText;

        // execute a replacement function if one exists
        if ( definitionObject.exec &&
             typeof definitionObject.exec == 'function' ) {
          // FIXME: In case of Ace Editor, the function shall not operate on
          // the text area, but on the editor. But since a lot functions
          // does not use the third args, this works in these cases. But
          // we shall fix it.
          definitionObject.exec( txt, selText, $('#gollum-editor-body'), selRange );
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
            repText = rt.replace( /\$[\d]/g, '' );
          }

          var cursorOffset = undefined;
            if (wholeLine == false) {
              // find position of $1 - this is where we will place the cursor
              repPosition = rt.indexOf('$1');


              // if the position of $1 doesn't exist, stick the cursor in
              // the middle
              if ( repPosition == -1 ) {
                repPosition = Math.floor( rt.length / 2 );
              }

              var tempString = rt.substring(0, repPosition);
              var verticalOffset = tempString.split('\n').length - 1;
              var horizontalOffset = repPosition;
              if ( verticalOffset > 0 ) {
                horizontalOffset = horizontalOffset - tempString.lastIndexOf('\n')
              }
              horizontalOffset = horizontalOffset + selTextLength;
              cursorOffset = [verticalOffset, horizontalOffset]
            }
          }

        // append if necessary
        if ( definitionObject.append &&
             typeof definitionObject.append == 'string' ) {
          repText += definitionObject.append;
        }

        if ( repText ) {
          $.GollumEditor.replaceSelection(repText, breakBefore, breakAfter, selRange, cursorOffset)
        }

      },

      isShown: function() {
        return ($('#gollum-editor-function-bar').is(':visible'));
      },

      refresh: function() {
        if ( EditorHas.functionBar() ) {
          debug('Refreshing function bar');
          if ( LanguageDefinition.isValid() ) {
            FunctionBar.deactivate();
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
          if ( $('#function-help').attr('disabled') ) {
            $('#function-help').attr('disabled', false);
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
          $('#function-help').attr('disabled', true);
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
          $('#function-help').attr('disabled', true);
        }
        if ( Help.isShown() ) {
          Help.hide();
        }
      } else {
        Help._ACTIVE_HELP_LANG = name;
        if ( $("#function-help").length ) {
          if ( $('#function-help').attr('disabled') ) {
            $('#function-help').attr('disabled', false);
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
  $.GollumEditor.replaceSelection = function( repText, breakBefore, breakAfter, selRange, cursorOffset ) {
    var editor = window.ace_editor;
    var newlinesPrefixed = 0;
    if (selRange == undefined ) {
      var selRange = editor.selection.getRange();
    }

    if ( breakBefore == true ) {
      var previousLine = editor.session.doc.getLine(selRange.start.row-1);
      if (selRange.start.column > 0) {
        repText = "\n\n" + repText
        newlinesPrefixed = 2;
      }
      else if (previousLine != "") {
        repText = "\n" + repText
        newlinesPrefixed = 1;
      }
    }

    if ( breakAfter == true ) {
      var nextLine = editor.session.doc.getLine(selRange.end.row+1);
      if (selRange.end.column < editor.session.doc.getLine(selRange.end.row).length) {
        repText = repText + "\n\n"
      }
      else if (nextLine != "") {
        repText = repText + "\n"
      }
    }

    editor.session.replace(selRange, repText);
    if (cursorOffset != undefined) {
      totalVerticalOffset = cursorOffset[0] + newlinesPrefixed + selRange.start.row;
      totalHorizontalOffset = cursorOffset[1] + selRange.start.column;
      editor.navigateTo(totalVerticalOffset, totalHorizontalOffset);
    }
    editor.focus();
  };

  // Placeholder exists as its own thing now
  $.GollumEditor.Placeholder = $.GollumPlaceholder;

})(jQuery);
