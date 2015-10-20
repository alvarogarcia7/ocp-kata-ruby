require 'rubygems'
require 'combination_generator'

RSpec.describe "#say" do
  before(:each) do
    rules = [Rule.boom].concat(create_set_of_rules)
    @fizz_buzz = FizzBuzz.new(*rules,
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

  it "multiples of seven are converted to Bang" do
    expect(say(7)).to eq "Bang"
  end

  it "multiples of three and seven are converted to FizzBang" do
    expect(say(3*7)).to eq "FizzBang"
  end

  it "multiples of five and seven are converted to BuzzBang" do
    expect(say(5*7)).to eq "BuzzBang"
  end

  it "multiples of three, five and seven are converted to FizzBuzzBang" do
    expect(say(3*5*7)).to eq "FizzBuzzBang"
  end

  it 'multiples of four or six are Boom' do
    expect(say(4)).to eq 'Boom'
  end

  def say a_number
    @fizz_buzz.say(a_number)
  end

  def select(amount, initial_rules)
    rules = []
    CombinationGenerator.new(amount, initial_rules).each do |element|
      rules << Rule.union(*element)
    end
    rules
  end

  def create_set_of_rules
    initial_rules = [Rule.fizz, Rule.buzz, Rule.bang]
    rules = []
    (initial_rules.length).downto(1).each{|n| rules = rules.concat(select(n, initial_rules))}
    rules
  end
end

class Rule
  def self.fizz
    lambda {|a_number| "Fizz" if a_number % 3 == 0}
  end

  def self.buzz
    lambda {|a_number| "Buzz" if a_number % 5 == 0}
  end

  def self.bang
    lambda {|a_number| "Bang" if a_number % 7 == 0}
  end

  def self.boom
    lambda {|a_number| "Boom" if a_number % 4 == 0}
  end

  def self.to_string
    lambda {|a_number| a_number.to_s}
  end

  def self.union *rules
    lambda {|a_number|
      all_rules = rules.map {|rule| rule.call a_number}
      all_rules.join("") if all_rules.none? {|x| x.nil?} }
  end

end

class FizzBuzz
  def initialize *rules
    @rules = *rules
  end

  def say a_number
    @rules.map {|rule| rule.call a_number}.compact.first
  end
end