require 'rubygems'
require 'combination_generator'

RSpec.describe "Open-Close Kata" do

  def say a_number
    @fizz_buzz.say(a_number)
  end

  describe 'with the specification pattern' do
    before(:each) do
      rules = [Rule.or(->x{x == 2}, ->x{x == 4}).then{|x| "Pair_#{x}"},
              Rule.if(->x {x == 0}).then{|x| x.to_s},
              Rule.and(->x{x % 3 == 0}, ->x{x % 2 != 0}).then{|x| "Multiple_3"},
              Rule.and(->x{x % 3 == 0}, ->x{x % 2 == 0}).then{|x| "Multiple_3,2"},
              Rule.not(->x{x > 0}).then{|x| "Negative_#{-x}"},
      ]
      @fizz_buzz = FizzBuzz.new(*rules)
    end

    it 'apply a simple rule described by a specification' do
      expect(say(0)).to eq "0"
    end

    it 'apply a rule with A or B' do
      expect(say(2)).to eq "Pair_2"
      expect(say(4)).to eq "Pair_4"
    end

    it 'apply a rule with A and B' do
      expect(say(3)).to eq "Multiple_3"
      expect(say(6)).to eq "Multiple_3,2"
    end

    it 'apply a rule with NOT A' do
      expect(say(-1)).to eq "Negative_1"
    end
  end

  describe 'with a chain of rules' do

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
      expect(say(6)).to eq 'Boom'
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
      rules_size = (initial_rules.length).downto(1)
      rules_size.each{|n| rules = rules.concat(select(n, initial_rules))}
      rules
    end
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
    lambda {|a_number| "Boom" if a_number % 4 == 0 or a_number % 6 == 0}
  end

  def self.to_string
    lambda {|a_number| a_number.to_s}
  end

  def self.union *rules
    lambda {|a_number|
      all_rules = rules.map {|rule| rule.call a_number}
      all_rules.join("") if all_rules.none? {|x| x.nil?} }
  end

  def initialize &predicate
    @predicate = predicate
  end

  def self.if predicate
    self.new {|a_number| predicate.call a_number}
  end

  def self.apply_to_all predicates, a_number
    predicates.map {|current| current.call a_number}
  end

  def self.or *predicates
    self.new {|a_number| apply_to_all(predicates, a_number).reduce(false) {|acc, e| acc or e}}
  end

  def self.and *predicates
    self.new {|a_number| apply_to_all(predicates, a_number).reduce(true) {|acc, e| acc and e}}
  end

  def self.not predicate
    self.new {|a_number| not predicate.call a_number}
  end

  def then &action
    FilteringAction.new(@predicate, action)
  end

  def call a_number
    @predicate.call a_number
  end

end

class FilteringAction
  def initialize predicate, action
    @predicate = predicate
    @action = action
  end

  def call a_number
    @action.call a_number if @predicate.call a_number
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