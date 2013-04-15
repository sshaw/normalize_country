module NormalizeCountry
  module Countries
    BR = Country.new("Brazil",
                     :iso2 => "BR",
                     :iso3 => "BRA")

    GB = Country.new("United Kingdom",
                     :iso2    => "GB",
                     :iso3    => "GBR",
                     :aliases => ["Britain",
                                  "U.K.",
                                  "United Kingdom of Great Britain and Northern Ireland"])

    US = Country.new("United States",
                     :iso2    => "US",
                     :iso3    => "USA",
                     :aliases => ["U.S.",
                                  "USA",
                                  "U.S.A.",
                                  "United States of America",
                                  "United States of America, The",
                                  "The United States of America"])

    MAPPING = {}
    constants.map do |name|
      klass = const_get(name)
      MAPPING.merge! klass.to_hash
    end

    def self.[](name)
      MAPPING[name]
    end
  end
end
