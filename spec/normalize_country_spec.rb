require "minitest/autorun"
require "normalize_country"

describe NormalizeCountry do
  COUNTRY_COUNT = 247

  it "normalizes to a country's ISO name by default" do
    NormalizeCountry.convert("USA").must_equal("United States")
  end

  it "is case insensitive" do
    NormalizeCountry.convert("usa").must_equal("United States")
    NormalizeCountry.convert("UsA").must_equal("United States")
  end

  it "ignores extra spaces" do
    NormalizeCountry.convert(" United   States of   America  ").must_equal("United States")
  end

  it "normalizes a country's aliases" do
    %w[America U.S. U.S.A.].each { |v| NormalizeCountry.convert(v).must_equal("United States") }
  end

  {:alpha2 => "US", :alpha3 => "USA", :ioc => "USA", :iso_name => "United States", :numeric => "840", :official => "United States of America", :fifa => "USA"}.each do |spec, expect|
    it "normalizes to #{spec}" do
      NormalizeCountry.convert("America", :to => spec).must_equal(expect)
    end
  end

  it "returns nil if the normalization target is unknown" do
    NormalizeCountry.convert("USA", :to => :wtf).must_be_nil
  end

  it "has a function form" do
    NormalizeCountry("USA", :to => :ioc).must_equal("USA")
  end

  describe ".to_h" do
    before { NormalizeCountry.to = :numeric }
    after  { NormalizeCountry.to = :iso_name }

    describe "without a :to option" do
      it "uses the format option as the key and the default :to option as the value" do
        hash = NormalizeCountry.to_h(:alpha3)
        hash.must_be_instance_of Hash
        hash["USA"].must_equal "840"
        hash["GBR"].must_equal "826"
        hash.size.must_equal COUNTRY_COUNT
      end
    end

    describe "with a :to option" do
      it "uses the format option as the key and the :to option as the value" do
        hash = NormalizeCountry.to_h(:alpha3, :to => :alpha2)
        hash.must_be_instance_of Hash
        hash["USA"].must_equal "US"
        hash["GBR"].must_equal "GB"
        hash.size.must_equal COUNTRY_COUNT
      end
    end

    describe "with an unknown format argument" do
      it "returns an empty Hash" do
        hash = NormalizeCountry.to_h(:wtf)
        hash.must_be_instance_of Hash
        hash.must_be_empty

        hash = NormalizeCountry.to_h(:alpha2, :to => :wtf)
        hash.must_be_instance_of Hash
        hash.must_be_empty
      end
    end
  end

  describe ".to_a" do
    describe "without a format argument" do
      before { NormalizeCountry.to = :numeric }
      after  { NormalizeCountry.to = :iso_name }

      it "returns an Array of countries in the default format" do
        list = NormalizeCountry.to_a
        list.must_be_instance_of Array
        list.must_include "840" # US
        list.must_include "826" # GB
        list.size.must_equal COUNTRY_COUNT
      end
    end

    describe "with a format argument" do
      it "returns an Array of countries in the given format" do
        list = NormalizeCountry.to_a(:alpha3)
        list.must_be_instance_of Array
        list.must_include "USA"
        list.must_include "GBR"
        list.size.must_equal COUNTRY_COUNT
      end
    end

    describe "with an unknown format argument" do
      it "returns an empty Array" do
        list = NormalizeCountry.to_a(:wtf)
        list.must_be_instance_of Array
        list.must_be_empty
      end
    end
  end

  describe ".formats" do
    it "returns a list of supported formats" do
      expected = [:alpha2, :alpha3, :fifa, :ioc, :iso_name, :numeric, :official, :short, :simple]
      formats  = NormalizeCountry.formats

      # Ugh, support this in 1.8.7 for a least one version
      if Symbol < Comparable
        formats.sort.must_equal(expected.sort)
      else
        formats.sort_by { |f| f.to_s }.must_equal(expected.sort_by { |f| f.to_s })
      end
    end
  end

  describe "when a default is set" do
    before { NormalizeCountry.to = :alpha2 }
    after  { NormalizeCountry.to = :iso_name }

    it "normalizes to the default when no target is given" do
      NormalizeCountry.convert("United States").must_equal("US")
    end

    it "normalizes to the target when one is given" do
      NormalizeCountry.convert("United States", :to => :alpha3).must_equal("USA")
    end
  end
end
