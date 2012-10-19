# Custom RSpec matchers that use methods from the File API

RSpec::Matchers.define :be_a_directory do 
  match do |dir| 
    File.directory?(dir) 
  end
end

RSpec::Matchers.define :exist do 
  match do |match| 
    File.exists?(match) 
  end
end