require 'spec_helper'

describe "A Git Actor" do
  
  it "modifies output and offset" do
    t = Time.now
    a = Actor.new("Tom Werner", "tom@example.com")
    pieces = a.output(t).split(" ")
    offset = pieces.pop
    output = pieces * ' '
    expect(output).to eql "Tom Werner <tom@example.com> #{t.to_i}" 
    expect(offset).to match /-?\d{4}/
  end
  
  it "creates an actor by person_ident" do
    a = Actor.new_from_person_ident(PersonIdent.new('Super Mario', 'mario@super.org'))
    expect(a.name).to eq 'Super Mario'
    expect(a.email).to eq 'mario@super.org'
  end

  # from_string

  it "seperates name and email from a given string" do 
    a = Actor.from_string("Tom Werner <tom@example.com>")
    expect(a.name).to eq "Tom Werner"
    expect(a.email).to eq "tom@example.com"
  end

end