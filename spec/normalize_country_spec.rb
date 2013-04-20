require "minitest/autorun"
require "normalize_country"

describe NormalizeCountry do
  it "normalizes to a country's ISO name by default" do
    NormalizeCountry.normalize("USA").must_equal("United States")
  end

  it "is case insensitive" do
    NormalizeCountry.normalize("usa").must_equal("United States")
    NormalizeCountry.normalize("america").must_equal("United States")
  end

  it "ignores extra spaces" do
    NormalizeCountry.normalize(" United   States of   America  ").must_equal("United States")
  end
end
