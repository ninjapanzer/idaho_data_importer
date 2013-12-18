require File.expand_path('../lib/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = "arbitrary-data-importer"
  gem.version       = ArbitraryDataImporter::VERSION
  gem.summary       = %q{Collection of tools for working with structured data files}
  gem.description   = gem.summary

  gem.authors       = ["Paul Scarrone"]
  gem.email         = "pscarrone@thinkthroughmath.com"
  gem.homepage      = "https://github.com/thinkthroughmath/idaho_data_importer"

  gem.add_runtime_dependency 'json'
  gem.add_runtime_dependency 'sqlite3'
  gem.add_runtime_dependency 'pg'
  gem.add_runtime_dependency 'sequel'
  gem.add_runtime_dependency 'redis'

  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-expectations'
  gem.add_development_dependency 'require_all'

  gem.files         = ['README.md'] + Dir['lib/*.rb']
  gem.test_files    = Dir['spec/**/*.rb']
  gem.require_paths = ["lib"]
end
