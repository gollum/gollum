const htmlDecode = (input) => {
  const doc = new DOMParser().parseFromString(input, "text/html");
  return doc.documentElement.textContent;
}

$(document).ready( function () {
  
  replace_blocks = function (pre, data) {
    pre.html(data['value']['value'][0])
  }
  
  var knitr = function () {
    $( "pre.knitr" ).each(function (index) {
      var pre = $(this)
      code = $(this).children("code")
      knitr_block =  htmlDecode(('```' + code.attr('class') + "\n" + code.html() + "\n```\n")).replace(/"/g, '\\"'); 
      knitr_cmd = "doc <- \"" + knitr_block + "\"\nlibrary(knitr)\nprint(knitr::knit2html(text = doc, fragment.only = TRUE, quiet = TRUE))"
      rserve.eval(knitr_cmd, function (err, result) { if (err === null) { replace_blocks(pre, result);  } } )
    })
  }
  
  var rserve = Rserve.create({
    host: 'ws://127.0.0.1:2376',
    on_connect: knitr
  });

})