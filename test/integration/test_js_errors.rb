require_relative '../capybara_helper'

def expected_errors
  Regexp.union([
    %r{Refused to apply style from 'http:.*/gollum/create/custom.css'},
    %r{.*/gollum/create/math.config.js - Failed to load resource: the server responded with a status of 403},
    %r{Refused to execute script from .*/gollum/create/math.config.js}
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
      math: :mathjax,
      mermaid: true,
      math_config: 'math.config.js'
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

  test 'no unexpected errors in preview tab' do
    visit '/gollum/edit/Bilbo-Baggins'
    click_on 'Preview'
    Timeout.timeout(Capybara.default_max_wait_time) do
      loop until mathjax_ready?(page)
    end
    log = console_log(page)
    assert_only_expected_errors(log)
  end

  test 'no unexpected errors on editor' do
    visit '/gollum/edit/Bilbo-Baggins'

    formats =  find(:id, 'wiki_format')
    commit_msg_field = find(:id, 'gollum-editor-message-field')
    options_for_select(formats).each do |opt|
      select opt.text, from: 'wiki_format'
      assert commit_msg_field.value.include?(opt.value)
      log = console_log(page)
      assert_only_expected_errors(log)
    end

    bindings =  find(:id, 'keybinding')
    options_for_select(bindings).each do |opt|
      select opt.text, from: 'keybinding'
      log = console_log(page)
      assert_only_expected_errors(log)
    end
  end

  teardown do
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end
end
