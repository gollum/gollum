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


