source 'https://rubygems.org'
gem 'rails', '3.2.12'
gem 'rake'

gem 'thin'
gem 'multi_json', '1.7.0'
gem "settingslogic"
gem 'sunspot_solr'
gem 'ruby-openid'
gem 'rack-contrib'
gem 'rack-openid'

# memcache
gem 'memcache-client'

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
  gem 'compass'
  gem 'uglifier', '>= 1.0.3'
  gem 'jquery-rails'
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
# RABL for API / JSON
gem 'rabl'
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

# Background tasks
gem 'delayed_job', '~> 2.1'

# HAML support
gem "haml"
gem "haml-rails"

# Image uploads
gem 'carrierwave'
gem 'fog'

gem "closure-compiler"

# paperclip -- for attaching files to requests
gem 'paperclip'


# notifier for production errors
gem "airbrake"
gem "xray", :require => "xray/thread_dump_signal_handler"

# new relic RPM
gem 'newrelic_rpm'

# oauth
gem 'oauth'
gem 'facebooker2'

gem 'will_paginate', '~> 3.0.pre2'

gem "validates_captcha"
gem "okkez-open_id_authentication"

gem "acts-as-taggable-on"

gem 'mechanize'
#gem 'formageddon', '0.0.0', :require => 'formageddon', :path => '/Users/aross/Sites/formageddon'
gem 'formageddon', :git => 'git://github.com/opencongress/formageddon.git'


group :test, :development do
  gem 'autotest'
  gem 'silent-postgres'	# Quieter postgres log messages

  gem 'rspec-rails', '~> 2.4'
  gem 'cucumber'
  gem 'webrat'
  gem 'selenium-client'

  gem 'capybara'

  
  gem 'guard'
  gem 'guard-livereload'
end
