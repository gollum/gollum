require 'spec_helper'

describe "A Git Actor" do
  
  it "should modify output and offset" do
    t = Time.now
    a = Actor.new("Tom Werner", "tom@example.com")
    pieces = a.output(t).split(" ")
    offset = pieces.pop
    output = pieces * ' '
    output.should eql "Tom Werner <tom@example.com> #{t.to_i}" 
    offset.should match /-?\d{4}/
  end
  
  it "should create an actor by person_ident" do
    a = Actor.new_from_person_ident(PersonIdent.new('Super Mario', 'mario@super.org'))
    a.name.should == 'Super Mario'
    a.email.should == 'mario@super.org'
  end

  # from_string

  it "should seperate name and email from a given string" do 
    a = Actor.from_string("Tom Werner <tom@example.com>")
    a.name.should == "Tom Werner"
    a.email.should == "tom@example.com"
  end

end