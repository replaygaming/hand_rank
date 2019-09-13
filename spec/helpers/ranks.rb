module RanksHelper
  def ranks
    @ranks ||= {}.tap do |acc|
      %w[2 3 4 5 6 7 8 9 T J Q K A].each_with_index do |rank, ri|
        %w[c d h s].each_with_index { |suit, si| acc["#{rank}#{suit}"] = ri * 4 + si + 1 }
      end
    end
  end
end

RSpec.configure do |config|
  config.include RanksHelper
  config.extend RanksHelper
end
