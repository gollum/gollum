require 'logger'

module RJGit

  begin
    require 'java'
    Dir["#{File.dirname(__FILE__)}/../java/jars/*.jar"].each { |jar| require jar }    
  rescue LoadError
    puts "You need to be running JRuby to use this gem."
    raise
  end

  @logger ||= ::Logger.new(STDOUT)
  
  def self.version
    VERSION
  end
  
end

# internal requires
  begin
    Dir["#{File.dirname(__FILE__)}/*.rb"].each do |file| 
      require file
    end
  end
