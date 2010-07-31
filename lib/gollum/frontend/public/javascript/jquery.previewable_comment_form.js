(function($){
  $.fn.previewableCommentForm = function(options){
    var opts = $.extend({}, $.fn.previewableCommentForm.defaults, options);

    return this.each(function(){
      var wrapper = $(this)
      var input   = wrapper.find('textarea')
      var output  = wrapper.find('.content-body')
      var error   = wrapper.prev('.comment-form-error')
      var button  = wrapper.find('.form-actions button')
      var text    = input.val()
      var dirty   = false
      var request = null

      dirtyInputs = $.merge(wrapper.find('.preview-dirty'), input)
      dirtyInputs.blur(function(){
        if (text != input.val()){
          dirty = true
          text = input.val()
        }
        updatePreview()
      })

      var updatePreview = function(force){
        if (!dirty && !force) return
        if ($.trim(text) == ""){ // empty input
          output.html("<p>Nothing to preview</p>")
          return
        }
        output.html("<p>Loading preview&hellip;</p>")
        if (request) request.abort()
        var params = $.extend({"text": text}, opts.previewOptions)
        request = $.post(opts.previewUrl, params, function(data) {
          output.html(data)
          opts.onSuccess.call(output)
        })
      }
      updatePreview(true)

      // Custom validation
      wrapper.closest('form').submit(function(){
        error.hide()
        if ( $.trim(input.val()) == "" ){
          error.show()
          return false
        }
        button.attr('disabled', 'disabled')
      })
    })
  }

  $.fn.previewableCommentForm.defaults = {
    previewUrl: "/preview",
    previewOptions: {},
    onSuccess: function() { }
  }
})(jQuery);
