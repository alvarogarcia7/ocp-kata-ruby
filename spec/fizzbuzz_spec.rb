RSpec.describe "#say" do
  before(:each) do
    @fizz_buzz = FizzBuzz.new(Rule.union(Rule.fizz, Rule.buzz),
                              Rule.fizz,
                              Rule.buzz,
                              Rule.to_string)
  end
  it "simple numbers are converted to text" do
    expect(say(1)).to eq "1"
    expect(say(2)).to eq "2"
  end

  it "multiples of three are converted to Fizz" do
    expect(say(3)).to eq "Fizz"
  end

  it "multiples of five are converted to Buzz" do
    expect(say(5)).to eq "Buzz"
  end

  it "multiples of three and five are converted to FizzBuzz" do
    expect(say(3*5)).to eq "FizzBuzz"
  end

  def say a_number
    @fizz_buzz.say(a_number)
  end
end

class Rule
  def self.fizz
    lambda {|a_number| "Fizz" if a_number % 3 == 0}
  end

  def self.buzz
    lambda {|a_number| "Buzz" if a_number % 5 == 0}
  end

  def self.to_string
    lambda {|a_number| a_number.to_s}
  end

  def self.union *rules
    lambda {|a_number| rules.map {|rule| rule.call a_number}.join("") if a_number % 15 == 0}
  end

end

class FizzBuzz
  def initialize *rules
    @rules = *rules
  end

  def say a_number
    @rules.map {|rule| rule.call a_number}.select {|text| not text.nil?}.first
  end
end