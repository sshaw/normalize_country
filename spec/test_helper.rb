class Minitest::Spec

  def self.it_extends_default_list
    it "extends a list of default countries" do
      list = NormalizeCountry.to_a(:iso_name)
      list.size.must_equal COUNTRY_COUNT + 2
      ["Soviet Union", "Czechoslovakia"].each { |name| list.must_include(name) }
    end
  end

  def self.it_converts_extended_countries
    it "converts extended countries" do
      {
        "Soviet Union"   => { :alpha2 => "SU", :iso_name => "Soviet Union", :short => "USSR" },
        "Czechoslovakia" => { :alpha2 => "CS", :iso_name => "Czechoslovakia" }
      }.each do |name, (spec, expect)|
        NormalizeCountry.convert(name, to: spec).must_equal(expect)
      end
    end
  end
end