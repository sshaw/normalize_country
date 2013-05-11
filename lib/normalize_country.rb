require "yaml"

module NormalizeCountry
  VERSION = "0.1.0"
  Countries = {}

  class << self
    attr_accessor :to

    def to
      @to ||= :iso_name
    end

    def convert(name, options = {})
      country = country_for(name)
      return unless country
      country[ options[:to] || to ]
    end

    def to_a(name = to)
      return [] if Countries.values.first[name].nil?
      Countries.values.uniq.map { |c| c[name] }.sort { |a, b| a <=> b }
    end

    def to_h(key, options = {})
      value = options[:to] || to
      countries = Countries.values
      return {} unless [ key, value ].all? { |v| countries.first[v] }

      hash = {}
      countries.each { |c| hash[ c[key] ] = c[value] }
      hash
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
          value.compact.map { |v| v.squeeze(" ").strip } :
          value ? value.squeeze(" ").strip : value
      end
    end

    def [](id)
      id = id.to_s
      return if id.empty? or id.to_sym == :aliases
      name = @mapping[id.to_sym]
      return name.dup if name
    end

    def names
      @names ||= @mapping.values.flatten.uniq.compact
    end
  end

  path = File.join(File.dirname(__FILE__), "normalize_country", "countries", "en.yml")
  data = YAML.load_file(path)
  data.values.each do |mapping|
    country = Country.new(mapping)
    country.names.map { |name| Countries[name.downcase.to_sym] = country }
  end
end

def NormalizeCountry(name, options = {})
  NormalizeCountry.convert(name, options)
end
