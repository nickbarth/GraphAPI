lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'graph_api/version'

Gem::Specification.new do |gem|
  gem.name          = 'graph-api'
  gem.date          = '2012-10-03'
  gem.version       = GraphAPI::VERSION
  gem.authors       = ['Nick Barth']
  gem.email         = ['nick@nickbarth.ca']
  gem.summary       = 'A Ruby Gem for simplifying authentication using the Facebook Graph API.'
  gem.description   = 'GraphAPI is a Ruby Gem created to simplifiy and help manage authentication using the Facebook Graph API.'
  gem.homepage      = 'https://github.com/nickbarth/GraphAPI'

  gem.add_dependency('rake')
  gem.add_dependency('json')
  gem.add_dependency('rest-client')
  gem.add_development_dependency('rspec')
  gem.add_development_dependency('debugger')

  gem.files         = `git ls-files`.split($/)
  gem.test_files    = gem.files.grep /spec/
  gem.require_paths = ['lib']
end
