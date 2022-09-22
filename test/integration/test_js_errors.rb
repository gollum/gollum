require_relative '../capybara_helper'

def console_log(page, level = :severe)
  page.driver.browser.logs.get(:browser).select{|log| log.level == level.to_s.upcase }
end

def expected_errors
  Regexp.union([
    %r{Refused to apply style from 'http:.*/gollum/create/custom.css'},
    %r{.*/gollum/create/mathjax.config.js - Failed to load resource: the server responded with a status of 403}
  ])
end

def assert_only_expected_errors(log)
  assert_equal [], log.reject {|err| err.message.match?(expected_errors) }
end

context 'Frontend with mathjax and mermaid' do
  include Capybara::DSL

  setup do
    @path = cloned_testpath("examples/lotr.git")
    @wiki = Gollum::Wiki.new(@path)
    Precious::App.set(:gollum_path, @path)
    Precious::App.set(:wiki_options, {
      mathjax: true,
      mermaid: true,
      mathjax_config: 'mathjax.config.js'
    })
    Capybara.app = Precious::App
  end

  test 'no unexpected errors on /' do
    visit '/'
    log = console_log(page)
    assert_only_expected_errors(log)
  end

  test 'no unexpected errors on /create/' do
    visit '/gollum/create/Foobar'
    log = console_log(page)
    assert_only_expected_errors(log)
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
