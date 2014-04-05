# ~*~ encoding: utf-8 ~*~
=begin
  Copyright 2006-2008 the V8 project authors. All rights reserved.
  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of Google Inc. nor the names of its
        contributors may be used to endorse or promote products derived
        from this software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
=end

# This file provides the following methods:
#   encodeURIComponent(componentString)
#   string.charCodeAt(k)

# component must be String
def encodeURIComponent(componentString)
  ::URI::URIEncodeComponent(componentString)
end

# define charCodeAt on String
class String
  def charCodeAt(k)
    # use scan, nil check, and unpack instead of ord for 1.8
    # 1.9 can simply use self[k].ord
    # http://stackoverflow.com/questions/7793177/split-utf8-string-regardless-of-ruby-version
    c = self.scan(/./mu)[k]
    return nil if c.nil?
    c.unpack('U')[0]
  end
end

module URI
  ;
  class << self
# Does the char code correspond to an alpha-numeric char.
# isAlphaNumeric('a'.ord) => true
# isAlphaNumeric(''.ord) => false
    def isAlphaNumeric(cc)
      # a - z
      if (97 <= cc && cc <= 122);
        return true
      end
      # A - Z
      if (65 <= cc && cc <= 90);
        return true
      end
      # 0 - 9
      if (48 <= cc && cc <= 57);
        return true
      end

      return false
    end

    def unescapePredicate(cc)
      if (isAlphaNumeric(cc));
        return true
      end
      # !
      if (cc == 33);
        return true
      end
      # '()*
      if (39 <= cc && cc <= 42);
        return true
      end
      # -.
      if (45 <= cc && cc <= 46);
        return true
      end
      # _
      if (cc == 95);
        return true
      end
      # ~
      if (cc == 126);
        return true
      end

      return false
    end

    def URIEncodeSingle(cc, result, index)
      x = (cc >> 12) & 0xF;
      y = (cc >> 6) & 63;
      z = cc & 63;
      octets = Array.new(3);
      if (cc <= 0x007F)
        octets[0] = cc;
      elsif (cc <= 0x07FF)
        octets[0] = y + 192;
        octets[1] = z + 128;
      else
        octets[0] = x + 224;
        octets[1] = y + 128;
        octets[2] = z + 128;
      end
      return URIEncodeOctets(octets, result, index);
    end

# Lazily initialized.
    @@hexCharCodeArray = 0;

    def URIAddEncodedOctetToBuffer(octet, result, index)
      result[index] = 37; # Char code of '%'.
      index         += 1
      result[index] = @@hexCharCodeArray[octet >> 4];
      index         += 1
      result[index] = @@hexCharCodeArray[octet & 0x0F];
      index += 1
      return index;
    end

    def URIEncodeOctets(octets, result, index)
      if (@@hexCharCodeArray == 0)
        @@hexCharCodeArray = [48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
                              65, 66, 67, 68, 69, 70];
      end
      index = URIAddEncodedOctetToBuffer(octets[0], result, index);
      if (octets[1]);
        index = URIAddEncodedOctetToBuffer(octets[1], result, index)
      end
      if (octets[2]);
        index = URIAddEncodedOctetToBuffer(octets[2], result, index)
      end
      if (octets[3]);
        index = URIAddEncodedOctetToBuffer(octets[3], result, index)
      end
      return index;
    end

    def URIEncodePair(cc1, cc2, result, index)
      u = ((cc1 >> 6) & 0xF) + 1;
      w = (cc1 >> 2) & 0xF;
      x = cc1 & 3;
      y = (cc2 >> 6) & 0xF;
      z = cc2 & 63;
      octets = Array.new(4);
      octets[0] = (u >> 2) + 240;
      octets[1] = (((u & 3) << 4) | w) + 128;
      octets[2] = ((x << 4) | y) + 128;
      octets[3] = z + 128;
      return URIEncodeOctets(octets, result, index);
    end

# component must be String
    def URIEncodeComponent(componentString)
      Encode(componentString, :unescapePredicate);
    end

# ECMA-262, section 15.1.3
    def Encode(uri, unescape)
      uriLength = uri.length;
      # We are going to pass result to %StringFromCharCodeArray
      # which does not expect any getters/setters installed
      # on the incoming array.
      result    = Array.new(uriLength);
      index = 0;
      k = -1;
      while ((k+=1) < uriLength) do
        cc1 = uri.charCodeAt(k);
        next if cc1.nil?
        if (self.send(unescape, cc1))
          result[index] = cc1;
          index += 1
        else
          if (cc1 >= 0xDC00 && cc1 <= 0xDFFF);
            throw("URI malformed")
          end
          if (cc1 < 0xD800 || cc1 > 0xDBFF)
            index = URIEncodeSingle(cc1, result, index);
          else
            k+=1;
            if (k == uriLength);
              throw("URI malformed")
            end
            cc2 = uri.charCodeAt(k);
            if (cc2 < 0xDC00 || cc2 > 0xDFFF);
              throw("URI malformed")
            end
            index = URIEncodePair(cc1, cc2, result, index);
          end
        end
      end
      # use .compact to get rid of nils from charCodeAt
      # return %StringFromCharCodeArray(result);
      # 'c' = 8 bit signed char
      # http://www.ruby-doc.org/core-1.9.3/Array.html#method-i-pack
      return result.compact.pack 'c*'
    end
  end # class << self
end # module
