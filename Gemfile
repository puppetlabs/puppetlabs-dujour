source "https://rubygems.org"

group :development, :test do
  gem 'puppet', '~> 4.5'
  gem 'facter', '~> 2.3'
  gem 'puppetlabs_spec_helper', '~> 1.2.1'
  gem 'rspec-puppet', '~> 2.4'
  gem 'rspec', '2.14'
  gem 'puppet-lint'
  gem 'fakefs', '0.6.7'
  gem 'hocon', '0.9.0'
end

if File.exists? "#{__FILE__}.local"
  eval(File.read("#{__FILE__}.local"), binding)
end
