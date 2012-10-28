# ~*~ encoding: utf-8 ~*~
require 'net/http'
require 'uri'
require 'open-uri'

class Gollum::WebSequenceDiagram
  WSD_URL = "http://www.websequencediagrams.com/index.php"

  # Initialize a new WebSequenceDiagram object.
  #
  # code  - The String containing the sequence diagram markup.
  # style - The String containing the rendering style.
  #
  # Returns a new Gollum::WebSequenceDiagram object
  def initialize(code, style)
    @code = code
    @style = style
    @tag = ""

    render
  end

  # Render the sequence diagram on the remote server and store the url to
  # the rendered image.
  #
  # Returns nil.
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

  # Gets the HTML IMG tag for the sequence diagram.
  #
  # Returns a String containing the IMG tag.
  def to_tag
    @tag
  end
end
