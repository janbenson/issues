source 'https://rubygems.org'
gem 'rails', '3.2.12'
gem 'rake', '10.0.3'
gem 'thin'
gem "settingslogic"
gem 'sunspot_solr'
gem 'ruby-openid'
gem 'rack-contrib'
gem 'rack-openid'

# RMagick
gem 'rmagick', '2.13.1'
gem "galetahub-simple_captcha", :require => "simple_captcha"
#gem 'simple_captcha'# , :git => 'git://github.com/galetahub/simple-captcha.git'

# database gems -- need both pg and mysql for app and wiki
gem 'pg'
gem 'mysql'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

gem 'jquery-rails'
# GovKit
gem "govkit"

# markup tools and parsers
gem 'simple-rss'
gem 'mediacloth'
gem 'hpricot'
gem 'RedCloth'
gem 'bluecloth'
gem 'htmlentities'
gem "json"
gem "nokogiri"
gem "acts_as_solr", "~> 1.3.3"
# spam protection
gem "defender"

group :deployment do
  gem 'capistrano'
  gem 'capistrano-ext'
end

# To use ActiveModel has_secure_password
  gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
  gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# To use debugger
 gem 'debugger'
gem 'will_paginate', '~> 3.0.pre2'

gem "validates_captcha" 
gem "acts-as-taggable-on"


group :test, :development do
  gem 'silent-postgres'	# Quieter postgres log messages

  gem 'rspec-rails', '~> 2.4'
  gem 'webrat'
  gem 'selenium-client'
  gem 'capybara'
end

