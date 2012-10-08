Gem::Specification.new do |s|
  s.name            = "bigquery"
  s.version         = "0.2.8"
  s.authors         = ["Adam Bronte"]
  s.email           = "adam@brontesaurus.com"
  s.description     = "This library is a wrapper around the google-api-client ruby gem.\nIt's meant to make calls to BigQuery easier and streamlined."
  s.require_paths   = ["lib"]
  s.summary         = "A nice wrapper for Google Big Query"
  s.homepage        = "https://github.com/abronte/BigQuery"
  s.files           = ['lib/bigquery.rb']

  s.add_dependency  "google-api-client", ">= 0.4.6"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
end
