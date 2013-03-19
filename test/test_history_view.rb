# ~*~ encoding: utf-8 ~*~
require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))
require File.expand_path '../../lib/gollum/views/history', __FILE__

context "Precious::Views::History" do
  setup do
    @history = Precious::Views::History.new
  end

  test "string_to_code" do
    # Result must match the following Java code.
=begin
	    public static void main(String[] args) throws Exception {
		    final String s = "code@example.com";
		    final byte[] b = MessageDigest.getInstance("SHA1").digest(s.toString().getBytes("UTF-8"));
		    final int c = ((b[0] & 0xFF) << 24) | ((b[1] & 0xFF) << 16)
				    | ((b[2] & 0xFF) << 8) | (b[3] & 0xFF);
		    // 143327882
		    System.out.println(c);
	    }
=end
    actual = @history.string_to_code 'code@example.com'
    assert_equal 143327882, actual
  end
end
