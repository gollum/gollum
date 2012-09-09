
describe "A Git Actor" do
  
  it "should modify output and offset" do
    t = Time.now
    a = Actor.new("Tom Werner", "tom@example.com")
    pieces = a.output(t).split(" ")
    offset = pieces.pop
    output = pieces * ' '
    output.should eql "Tom Werner <tom@example.com> #{t.to_i}" 
    offset.should eql /-?\d{4}/
  end

  # from_string

  it "should seperate name and email from a given string" do 
    a = Actor.from_string("Tom Werner <tom@example.com>")
    a.name.should == "Tom Werner"
    a.email.should == "tom@example.com"
  end

  it "should handle a string with just a name" do 
    a = Actor.from_string("Tom Werner")
    a.name.should == "Tom Werner"
    a.email.should == nil
  end

end