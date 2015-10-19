RSpec.describe "#say" do
  it "simple numbers are converted to text" do
    expect(say(1)).to eq "1"
    expect(say(2)).to eq "2"
  end
end

def say a_number
  a_number.to_s
end