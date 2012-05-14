(function($) {

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

 $.GollumPlaceholder = Placeholder;

})(jQuery);