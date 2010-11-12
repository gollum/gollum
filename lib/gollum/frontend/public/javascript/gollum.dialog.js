/**
  *  Dialog
  *  Used by FunctionBar & internally to display editor-specific messages,
  *  inputs and more.
  *
  */
  
(function($) {
   
   var Dialog = {
     
     markupCreated: false,
     
     attachEvents: function( evtOK ) {
       $('#gollum-editor-action-ok').click(function( e ) {
        Dialog.eventOK( e, evtOK );
       });
       $('#gollum-editor-action-cancel').click( Dialog.eventCancel );
     },
   
     createFieldMarkup: function( fieldArray ) {
       var fieldMarkup = '<fieldset>';
       for ( var i=0; i < fieldArray.length; i++ ) {
         if ( typeof fieldArray[i] == 'object' ) {
           fieldMarkup += '<div class="field">';
           switch ( fieldArray[i].type ) {
           
             // only text is supported for now
             case 'text':
             case 'code':
             default:
              fieldMarkup += Dialog.createFieldText( fieldArray[i] );
              break;
           
           }
           fieldMarkup += '</div>';
         }
       
       }
       fieldMarkup += '</fieldset>';
       return fieldMarkup;
     },
   
     createFieldText: function( fieldAttributes ) {
       var html = '';
     
       if ( fieldAttributes.name ) {
         html += '<label';
         if ( fieldAttributes.id ) {
           html += ' for="' + fieldAttributes.name + '"';
         }
         html += '>' + fieldAttributes.name + '</label>';
       }
     
       html += '<input type="text"';
     
       if ( fieldAttributes.id ) {
         html += ' name="' + fieldAttributes.id + '"'
         if ( fieldAttributes.type == 'code' ) {
           html+= ' class="code"';
         }
         html += ' id="gollum-editor-dialog-generated-field-' +
                 fieldAttributes.id + '">';
       }
     
       return html;
     },
   
     createMarkup: function( title, body ) {
       Dialog.markupCreated = true;
       return  '<div id="gollum-editor-dialog">' +
               '<div id="gollum-editor-dialog-inner">' +
               '<div id="gollum-editor-dialog-bg">' +
               '<div id="gollum-editor-dialog-title"><h4>' + 
                 title +'</h4></div>' +
               '<div id="gollum-editor-dialog-body">' + body + '</div>' + 
               '<div id="gollum-editor-dialog-buttons">' + 
               '<a href="#" title="Cancel" id="gollum-editor-action-cancel" ' + 
               'class="minibutton">Cancel</a>' +
               '<a href="#" title="OK" id="gollum-editor-action-ok" '+ 
               'class="minibutton">OK</a>' +
               '</div>' + 
               '</div>' + 
               '</div>';
     },
   
     eventCancel: function( e ) {
       e.preventDefault();
       debug('Cancelled dialog.');
       Dialog.hide();
     },
   
     eventOK: function( e, evtOK ) {
       e.preventDefault();
     
       var results = [];
       // get the results from each field and build them into the object
       $('#gollum-editor-dialog-body input').each(function() {
         results[$(this).attr('name')] = $(this).val();
       });
     
       // pass them to evtOK if it exists (which it should)
       if ( evtOK &&
            typeof evtOK == 'function' ) {
         evtOK( results );
       }
       Dialog.hide();
     },

     hide: function() {
       $('#gollum-editor-dialog').animate({ opacity: 0 }, {
          duration: 200,
          complete: function() {
            $('#gollum-editor-dialog').removeClass('active');
          }
        });
     },
   
     init: function( argObject ) {
       var title = '';
       var body = '';
     
       // bail out if necessary
       if ( !argObject || 
            typeof argObject != 'object' ) {
         debug('Editor Dialog: Cannot init; invalid init object');
         return;
       }
     
       // alright, build out fields
       if ( argObject.fields && typeof argObject.fields == 'object' ) {
         body = Dialog.createFieldMarkup( argObject.fields );
       }
     
       if ( argObject.title && typeof argObject.title == 'string' ) {
         title = argObject.title;
       }
     
       if ( Dialog.markupCreated ) {
         $('#gollum-editor-dialog').remove();
       }
       var $dialog = $( Dialog.createMarkup( title, body ) );
       $('body').append( $dialog );
       if ( argObject.OK &&
            typeof argObject.OK == 'function' ) {
         Dialog.attachEvents( argObject.OK );
       }
       Dialog.show();
     },
   
     show: function() {
       if ( !Dialog.markupCreated ) {
         debug('Dialog: No markup to show. Please use init first.')
       } else {
         debug('Showing dialog');
          $('#gollum-editor-dialog').animate({ opacity: 0 }, {
            duration: 1,
            complete: function() {
              $('#gollum-editor-dialog').addClass('active');
              Dialog.position(); // position this thing
              $('#gollum-editor-dialog').animate({ opacity: 1 }, {
                duration: 500
              });
            }
          });
       }
     },
   
     position: function() {
       var dialogHeight = $('#gollum-editor-dialog-inner').height();
       debug(dialogHeight);
       $('#gollum-editor-dialog-inner')
         .css('height', dialogHeight + 'px')
         .css('margin-top', -1 * parseInt( dialogHeight / 2 )); 
     }
   
  }; 
  
  $.GollumDialog = Dialog;
 
})(jQuery);