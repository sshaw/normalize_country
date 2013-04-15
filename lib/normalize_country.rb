module NormalizeCountry  
  class << self
    attr_accessor :to
    
    def to
      @to ||= :iso_name
    end

    def aliases(name, options = {})
      country = Countries[name.to_sym]
      country ? country.aliases : []
    end
    
    def normalize(name, options = {})
      country = Countries[name.to_sym]
      return unless country
      country[ options[:to] || to ]
    end
  end
  
  class Country
    def initialize(name, mapping = {})
      @iso_name = name
      @mapping  = mapping        
      @mapping[:iso_name] = @iso_name
    end
    
    def [](key)
      @mapping[key]
    end

    def []=(key, value)
      @mapping[key] = value
    end
    
    def names
      @mapping.values.flatten.uniq.compact
    end
    
    def aliases
      @mapping[:aliases] ||= []
    end
    
    def to_hash
      hash = {}
      names.each { |name| hash[name.to_sym] = self }
      hash
    end
  end
end

def NormalizeCountry(name, options = {})
  NormalizeCountry.normalize(name, options)
end

require "normalize_country/countries"
