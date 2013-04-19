require "minitest/autorun"
require "normalize_country"

describe NormalizeCountry do
  it "normalizes to a country's ISO name by default" do
    NormalizeCountry.normalize("USA").must_equal("United States")
  end
end
