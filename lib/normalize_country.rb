require "yaml"

module NormalizeCountry
  VERSION = "0.2.0"
  Countries = {}

  class << self
    attr_accessor :to

    def to
      @to ||= :iso_name
    end

    def formats
      @formats ||= Countries.values.flat_map(&:formats).uniq #  format might not be defined for all countries
    end

    def convert(name, options = {})
      country = country_for(name)
      return unless country
      country[ options[:to] || to ]
    end

    def to_a(name = to)
      return [] if Countries.values.find { |c| c[name] }.nil?   # format might not be defined for all countries
      Countries.values.uniq.map { |c| c[name] }.compact.sort { |a, b| a <=> b }
    end

    def to_h(key, options = {})
      value = options[:to] || to
      countries = Countries.values
      return {} unless [ key, value ].all? { |v| countries.first[v] }

      hash = {}
      countries.each { |c| hash[ c[key] ] = c[value] }
      hash
    end

    def extend_countries(*args)
      args = args.flatten
      return if args.empty?

      if args.first.is_a?(Hash)
        args.each { |mapping| add_country(mapping, true) }
      else
        load_from_yaml(args.first, true)
      end
    end

    alias_method :add_countries, :extend_countries

    def reset!
      Countries.clear
      @to = @formats = nil

      load_from_yaml File.join(File.dirname(__FILE__), "normalize_country", "countries", "en.yml")
    end

    private

    def country_for(name)
      name = Country.format_id(name.to_s.downcase)
      return if name.empty?
      Countries[name.to_sym]
    end

    def add_country(mapping, merge = false)
      country = Country.new(mapping)

      if merge
        existing_country = Countries.values.find do |object|
          country.mapping.any? { |id, value| value && object[id] == value }
        end

        if existing_country
          country = existing_country.merge(country)
        end
      end

      country.names.each { |name| Countries[name.downcase.to_sym] = country }
    end

    def load_from_yaml(path, *add_country_args)
      data = YAML.load_file(path)
      data.values.each { |mapping| add_country(mapping, *add_country_args) }
    end
  end

  class Country
    attr_reader :mapping

    def initialize(config)
      raise ArgumentError, "country config must be a hash" unless Hash === config

      @mapping = {}
      config.each do |id, value|
        @mapping[id.to_sym] = Array === value ? value.compact.map { |v| self.class.format_id(v) }
                                              : self.class.format_id(value)
      end
    end

    def self.format_id(id)
      return unless id
      id.to_s.squeeze(" ").strip
    end

    def [](id)
      id = id.to_s
      return if id.empty? or id.to_sym == :aliases
      name = @mapping[id.to_sym]
      name.dup if name
    end

    def formats
      @formats ||= begin
        keys = @mapping.keys
        keys.delete(:aliases)
        keys
      end
    end

    def names
      @names ||= @mapping.values.flatten.uniq.compact
    end

    def merge(other)
      merged_mapping = mapping.merge(other.mapping) do |key, left, right|
        key == :aliases ? (left | right) : right
      end

      self.class.new(merged_mapping)
    end
  end

  reset!
end

def NormalizeCountry(name, options = {})
  NormalizeCountry.convert(name, options)
end
