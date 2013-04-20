require "yaml"

module NormalizeCountry
  VERSION = "0.0.1"
  Countries = {}

  class << self
    attr_accessor :to

    def to
      @to ||= :iso_name
    end

    def normalize(name, options = {})
      country = country_for(name)
      return unless country
      country[ options[:to] || to ]
    end

    private
    def country_for(name)
      name = name.to_s.downcase.strip.squeeze(" ")
      return if name.empty?
      Countries[name.to_sym]
    end    
  end

  class Country
    def initialize(config)
      raise ArgumentError, "country config must be a hash" unless Hash === config

      @mapping = {}
      config.each do |id, value|
        @mapping[id.to_sym] = Array === value ?
          value.map { |v| v } :
          value
      end
    end

    def [](id)
      id = id.to_s
      return if id.empty? or id.to_sym == :aliases
      @mapping[id.to_sym]
    end

    def names
      @names ||= @mapping.values.flatten.uniq.compact
    end
  end

  path = ENV["NORMALIZE_COUNTRY_DATAFILE"] || File.join(File.dirname(__FILE__), "normalize_country", "countries", "en.yml")
  data = YAML.load_file(path)
  data.values.each do |mapping|
    country = Country.new(mapping)
    country.names.map { |name| Countries[name.downcase.to_sym] = country }
  end
end

def NormalizeCountry(name, options = {})
  NormalizeCountry.normalize(name, options)
end
