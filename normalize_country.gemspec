require File.expand_path("../lib/normalize_country", __FILE__)
require "date"

Gem::Specification.new do |s|
  s.name        = "normalize_country"
  s.version     = NormalizeCountry::VERSION
  s.date        = Date.today
  s.summary     = "Convert country names and codes to a standard"
  s.description =<<-DESC
    Converts country names and codes from standardized and non-standardized names and abbreviations to one of the following:
    ISO 3166-1 (code/name/number), FIFA, IOC, a country's official name or shortened name, and Emoji.

    A list of default countries can also be extended by custom user data.

    Includes a small script to convert names/codes in a DB, XML or CSV file.
  DESC
  s.authors     = ["Skye Shaw"]
  s.executables << "normalize_country"
  s.email       = "skye.shaw@gmail.com"
  s.test_files  = Dir["spec/**/*.*"]
  s.extra_rdoc_files = %w[README.rdoc]
  s.files       = Dir["lib/**/*.{rb,yml}"] + s.test_files + s.extra_rdoc_files
  s.homepage    = "http://github.com/sshaw/normalize_country"
  s.license     = "MIT"
  s.add_development_dependency "rake", "~> 0.9"
  s.add_development_dependency "minitest"
end
