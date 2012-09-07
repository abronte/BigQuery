Gem::Specification.new do |s|
  s.name            = "bigquery"
  s.version         = "0.1.3"
  s.authors         = ["Adam Bronte"]
  s.email           = "adam@brontesaurus.com"
  s.description     = "This library is a wrapper around the google-api-client ruby gem.\nIt's meant to make calls to BigQuery easier and streamlined."
  s.require_paths   = ["lib"]
  s.summary         = "A nice wrapper for Google Big Query"
  s.homepage        = "https://github.com/abronte/BigQuery"
  s.files           = ['lib/bigquery.rb']
  s.add_dependency  "google-api-client"
end
