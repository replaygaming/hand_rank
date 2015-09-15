require "hand_rank/version"

module HandRank
  HOME = __FILE__.to_s.gsub('.rb','/')

  def self.get( hand )
    cards = hand.to_a.map{|c| c.to_i }
    self.rank( cards )
  end
end

require "hand_rank/hand_rank"