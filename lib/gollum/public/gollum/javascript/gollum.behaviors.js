function basicSelectSetSelection(select, value) {
   select.find('.SelectMenu-item').each(function () {
     $(this).attr('aria-checked', false);
     if($(this).attr('value') === value ) {
       $(this).attr('aria-checked', true);
       $(this).closest('details').find('summary span').text($(this).attr('value'));
     }
   });
}

function basicSelectGetSelection(select) {
  return select.find('.SelectMenu-item[aria-checked="true"]');
}

$(document).ready(function() {
  
  // Implement basic select behavior
  // Only one item can be selected at the same time
  // Close the select modal after selection
  $('.BasicSelect .SelectMenu-item').on('click', function(e) {
    e.preventDefault();
    selected = $(this);
    // find select menu context and uncheck all items for that context
    selected.parent('.SelectMenu-list').children('.SelectMenu-item').each(function () {
      $(this).attr('aria-checked', false);
    });
    // select clicked item
    selected.attr('aria-checked', true);
    // Change button text
    details = selected.closest('details');
    details.find('summary span').text(selected.text());
    // Close menu
    details.removeAttr('open');
    // Trigger change callback with selected value
    selected.trigger('change', selected.attr('value'));
    
    
  });

});