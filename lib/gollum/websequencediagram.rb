require 'net/http'
require 'uri'
require 'open-uri'

class Gollum::WebSequenceDiagram
  WSD_URL = "http://www.websequencediagrams.com/index.php"

  def initialize(code, style)
    @code = code
    @style = style
    @tag = ""

    render
  end

  def render
    response = Net::HTTP.post_form(URI.parse(WSD_URL), 'style' => @style, 'message' => @code)
    if response.body =~ /img: "(.+)"/
      url = "http://www.websequencediagrams.com/#{$1}"
      @tag = "<img src=\"#{url}\" />"
    else
      puts response.body
      @tag ="Sorry, unable to render sequence diagram at this time."
    end
  end

  def to_tag
    @tag
  end
end
