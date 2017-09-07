require "rails_helper"

RSpec.describe Entry do
  subject { described_class.new(url: "ciao") }

  it "has a complete_url" do
    expected = "https://www.cantierecreativo.net/ciao"
    expect(subject.complete_url).to eq(expected)
  end
end
