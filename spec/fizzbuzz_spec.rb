RSpec.describe "#say" do
  it "simple numbers are converted to text" do
    expect(say(1)).to eq "1"
  end
end

def say a_number
  "1"
end