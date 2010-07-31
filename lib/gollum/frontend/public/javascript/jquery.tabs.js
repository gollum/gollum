jQuery.fn.tabs = function(){

  var getAnchor = function(str) {
    return /#([a-z][\w.:-]*)$/i.exec(str)[1];
  }

  var windowHash = window.location.hash.substr(1);

  return this.each(function(){
    var selectedLink = null;
    var selectedContainer = null;

    $(this).find('li a').each(function(){
      // Find & hide the container
      var container = $('#' + getAnchor(this.href));
      if (container == []) return;
      container.hide();
      // Setup the click handlers for the tab links
      $(this).click(function(){
        var self = $(this)

        var switchTab = function(){
          if (selectedContainer) selectedContainer.hide();
          if (selectedLink) selectedLink.removeClass('selected');

          selectedContainer = container.show();
          selectedLink = self.addClass('selected');
        }

        if (self.attr('ajax')){
          self.addClass('loading')
          $.ajax({
            url: self.attr('ajax'),
            success: function(data){
              container.html(data)
              self.removeClass('loading')
              self[0].removeAttribute('ajax')
              switchTab()
            },
            failure: function(data){
              alert("An error occured, please reload the page")
            }
          })
        }else{
          switchTab()
        }

        return false;
      });

      if ($(this).hasClass('selected')) $(this).click();
    });

    // Try to match window.location.hash
    $(this).find("li a[href='#" + windowHash + "']").click()
    // Show one tab by default
    if (selectedContainer == null) $($(this).find('li a')[0]).click();
  });
};