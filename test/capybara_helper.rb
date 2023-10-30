require_relative 'helper'

require 'selenium-webdriver'
require 'capybara/dsl'

Selenium::WebDriver::Chrome.path = ENV['CHROME_PATH'] if ENV['CHROME_PATH']

CAPYBARA_DRIVER =
  if ENV['CI']
    :selenium_chrome_headless
  else
    ENV.fetch('CAPYBARA_DRIVER', :selenium_chrome).to_sym
  end

Capybara.default_driver = CAPYBARA_DRIVER
Capybara.enable_aria_label = true

if ENV['GOLLUM_CAPYBARA_URL']
  Capybara.configure do |config|
    config.run_server = false
    config.app_host = ENV['GOLLUM_CAPYBARA_URL']
  end
else
  Capybara.server = :webrick
end

def console_log(page, level = :severe)
  page.driver.browser.logs.get(:browser).select { |log| log.level == level.to_s.upcase }
end

def create_page(title:, content:)
  visit "/"

  click_on "New"
  fill_in "Page Name", with: title
  click_on "OK"

  assert_includes page.text, "Create New Page"

  page_title_field = find "input#gollum-editor-page-title"
  assert_includes page_title_field.value, title

  within "div.ace_content" do
    send_keys content
    assert page.text, content
  end

  assert page.current_path.start_with? "/gollum/create"

  click_on "Save"

  using_wait_time 10 do
    escaped_title = title.gsub(" ", "%20")
    assert page.current_path, "/#{escaped_title}.md"
  end
end

def wait_for_ajax
  # https://thoughtbot.com/blog/automatically-wait-for-ajax-with-capybara
  Timeout.timeout(Capybara.default_max_wait_time) do
    loop until page.evaluate_script('jQuery.active').zero?
  end
end

def options_for_select(select)
  select.all(:css, "option")
end

def mathjax_ready?(page)
  html = Nokogiri::HTML(page.html)
  html.css('.MathJax_Processing').empty? && html.css('.MathJax_Processed').empty?
end
