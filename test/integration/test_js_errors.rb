if ENV['CI'] || ENV['CAPYBARA'] then
  require File.expand_path(File.join(File.dirname(__FILE__), '..', 'helper'))
  require 'selenium-webdriver'
  require 'capybara/dsl'

  Capybara.default_driver = :selenium_headless
  Capybara.server = :webrick

  def console_log(page, level = :severe)
    page.driver.browser.logs.get(:browser).select{|log| log.level == level.to_s.upcase }
  end

  def expected_errors
    Regexp.union([
      %r{Refused to apply style from 'http:.*/gollum/create/custom.css'}
    ])
  end

  def assert_only_expected_errors(log)
    assert_equal [], log.reject {|err| err.message.match?(expected_errors) }
  end

  context 'Frontend with mathjax' do
    include Capybara::DSL
    
    setup do
      @path = cloned_testpath("examples/lotr.git")
      @wiki = Gollum::Wiki.new(@path)
      Precious::App.set(:gollum_path, @path)
      Precious::App.set(:wiki_options, {mathjax: true})
      Capybara.app = Precious::App
    end
    
    test 'no unexpected errors on /' do
      visit '/'
      log = console_log(page)
      assert_only_expected_errors(log)
    end
    
    test 'no unexpected errors on /create/' do
      visit '/create/Foobar'
      log = console_log(page)
      assert_only_expected_errors(log)
    end
    
    teardown do
      Capybara.reset_sessions!
      Capybara.use_default_driver
    end
  end
end