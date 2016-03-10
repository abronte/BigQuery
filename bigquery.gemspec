# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "big_query/version"

Gem::Specification.new do |s|
  s.name            = "bigquery"
  s.version         = BigQuery::VERSION
  s.authors         = ["Adam Bronte", "Andres Bravo"]
  s.email           = ["adam@brontesaurus.com", "andresbravog@gmail.com"]
  s.description     = "This library is a wrapper around the google-api-client ruby gem.
                       It's meant to make calls to BigQuery easier and streamlined."
  s.require_paths   = ["lib"]
  s.summary         = "A nice wrapper for Google Big Query"
  s.homepage        = "https://github.com/abronte/BigQuery"
  s.files           = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")

  s.add_dependency "google-api-client", "0.9.3"

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "pry-byebug"
end
