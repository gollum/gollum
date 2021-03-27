require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))
require 'selenium-webdriver'
require 'capybara'
require 'capybara/dsl'

def console_logs(page, level = :severe, &block)
  yield page.driver.browser.manage.logs.get(:browser).select{|log| log.level == level.to_s.upcase }
end

def expected_errors
  [
    %r{Refused to apply style from 'http:.*/gollum/create/custom.css'}
  ]
end

context 'Frontend with mathjax' do
  include Capybara::DSL
  
  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {mathjax: true})
    Capybara.app = Precious::App
    Capybara.default_driver = :selenium_chrome
    Capybara.server = :webrick
  end
  
  test 'expected asset errors' do
    test_routes = ['/', '/create/Foobar.rst']
    test_routes.each do |route|
      visit route
      console_logs(page) do |logs|
        expected_errors.each do |error|
          assert logs.find {|log| log.message.match?(error) }
        end
        assert logs.size == expected_errors.size # No other errors
      end
    end
  end
  
  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end