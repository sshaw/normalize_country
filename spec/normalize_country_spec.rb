require "minitest/autorun"
require "normalize_country"

describe NormalizeCountry do
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

  {:alpha2 => "US", :alpha3 => "USA", :ioc => "USA", :iso_name => "United States", :official => "United States of America", :fifa => "USA"}.each do |spec, expect| 
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
