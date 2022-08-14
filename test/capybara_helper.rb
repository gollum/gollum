require_relative 'helper'

require 'selenium-webdriver'
require 'capybara/dsl'

CAPYBARA_DRIVER =
  if ENV['CI']
    :selenium_chrome_headless
  else
    ENV.fetch('CAPYBARA_DRIVER', :selenium_chrome).to_sym
  end

Capybara.default_driver = CAPYBARA_DRIVER
Capybara.enable_aria_label = true
Capybara.server = :webrick

def console_log(page, level = :severe)
  page.driver.browser.logs.get(:browser).select { |log| log.level == level.to_s.upcase }
end


