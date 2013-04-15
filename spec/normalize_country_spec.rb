require "minitest/autorun"
require "normalize_country"

describe NormalizeCountry do
  it "normalizes to a country's ISO name by default" do
    NormalizeCountry.normalize("USA").must_equal("United States")
  end

  describe "aliases" do
    it "returns all of the aliases for the given country" do
      NormalizeCountry.aliases("USA").must_equal ["U.S.",
                                                 "USA",
                                                 "U.S.A.",
                                                 "United States of America",
                                                 "United States of America, The",
                                                 "The United States of America"]
    end

    it "normalizes a country's name to the requested alias" do
      NormalizeCountry.normalize("United States of America", :to => :iso3).must_equal("USA")
    end

    it "returns nil if the alias is unknown" do
      NormalizeCountry.normalize("United States of America", :to => :xxx).must_be_nil
    end

    describe "adding an alias" do
      before do
        @aliases = NormalizeCountry.aliases("United States") 
        @my_alias = "Los Estados Unidos"
        NormalizeCountry::Countries::US[:aliases] << @my_alias
      end

      after { NormalizeCountry::Countries::US[:aliases].delete(@my_alias) }

      it "is placed into the country's alias list" do
        aliases = NormalizeCountry.aliases("United States")
        aliases.must_include(@my_alias)
        aliases.must_include(@aliases)
      end

      it "does not interfere with other aliases" do
        NormalizeCountry.normalize("USA", :to => :iso2).must_equal("US")
      end

      it "can be normalized" do
        NormalizeCountry.normalize(@my_alias).must_equal("United States")
      end
    end

    describe "adding a named alias" do
      before do
        @ice_cube = "AmeriKKKa"
        NormalizeCountry::Countries::US[:ice_cube] = @ice_cube
      end

      # Uhhh
      after  { NormalizeCountry::Countries::US[:ice_cube] = nil }

      it "is placed into the country's alias list" do
        NormalizeCountry.aliases("USA").must_include(@ice_cube)
      end

      it "can be normalized" do
        NormalizeCountry.normalize(@ice_cube).must_equal("United States")
      end

      it "can be given as a normalization target" do
        NormalizeCountry.aliases("USA", :to => :ice_cube).must_equal(@ice_cube)
      end

      it "does not interfere with other aliases" do
        NormalizeCountry.normalize("USA", :to => :iso2).must_equal("US")
      end
    end
  end
end
