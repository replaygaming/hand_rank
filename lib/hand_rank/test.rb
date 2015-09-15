root_dir = File.expand_path File.dirname(__FILE__)
lib_dir = File.join( root_dir, 'lib' )
$LOAD_PATH << lib_dir

require 'hand_rank'

class Card
  class SuitError < ArgumentError
    def to_s
      "Suit must be one of Replay::Poker::Card::(#{SUIT_NAMES.map{|_,s| s[0..-2].upcase }.join('|') })"
    end
  end

  class ValueError < ArgumentError
    def to_s
      "Value must be a Fixnum between 1 and 14 or any of the strings: #{ VALUE_NAMES[2..-1].join(', ') }"
    end
  end

        AceOfSpades = :"🂡"
        TwoOfSpades = :"🂢"
      ThreeOfSpades = :"🂣"
       FourOfSpades = :"🂤"
       FiveOfSpades = :"🂥"
        SixOfSpades = :"🂦"
      SevenOfSpades = :"🂧"
      EightOfSpades = :"🂨"
       NineOfSpades = :"🂩"
        TenOfSpades = :"🂪"
       JackOfSpades = :"🂫"
      QueenOfSpades = :"🂭"
       KingOfSpades = :"🂮"

        AceOfHearts = :"🂱"
        TwoOfHearts = :"🂲"
      ThreeOfHearts = :"🂳"
       FourOfHearts = :"🂴"
       FiveOfHearts = :"🂵"
        SixOfHearts = :"🂶"
      SevenOfHearts = :"🂷"
      EightOfHearts = :"🂸"
       NineOfHearts = :"🂹"
        TenOfHearts = :"🂺"
       JackOfHearts = :"🂻"
      QueenOfHearts = :"🂽"
       KingOfHearts = :"🂾"

      AceOfDiamonds = :"🃁"
      TwoOfDiamonds = :"🃂"
    ThreeOfDiamonds = :"🃃"
     FourOfDiamonds = :"🃄"
     FiveOfDiamonds = :"🃅"
      SixOfDiamonds = :"🃆"
    SevenOfDiamonds = :"🃇"
    EightOfDiamonds = :"🃈"
     NineOfDiamonds = :"🃉"
      TenOfDiamonds = :"🃊"
     JackOfDiamonds = :"🃋"
    QueenOfDiamonds = :"🃍"
     KingOfDiamonds = :"🃎"

         AceOfClubs = :"🃑"
         TwoOfClubs = :"🃒"
       ThreeOfClubs = :"🃓"
        FourOfClubs = :"🃔"
        FiveOfClubs = :"🃕"
         SixOfClubs = :"🃖"
       SevenOfClubs = :"🃗"
       EightOfClubs = :"🃘"
        NineOfClubs = :"🃙"
         TenOfClubs = :"🃚"
        JackOfClubs = :"🃛"
       QueenOfClubs = :"🃝"
        KingOfClubs = :"🃞"

              Joker = :"🃟"

              SPADE = :"♠"
              HEART = :"♡"
            DIAMOND = :"♢"
               CLUB = :"♣"
              JOKER = :"🃟"

     SUITS = [ SPADE, HEART, DIAMOND, CLUB, JOKER ]
    VALUES = [ nil, :"A", :"2", :"3", :"4", :"5", :"6", :"7", :"8", :"9", :"10", :"J", :"Q", :"K", :"A" ]
    ABSOLUTE_VALUE = {
         CLUB => [ nil, 49, 1, 5,  9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 ],
      DIAMOND => [ nil, 50, 2, 6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50 ],
        HEART => [ nil, 51, 3, 7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51 ],
        SPADE => [ nil, 52, 4, 8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52 ],
        JOKER => [ nil ],
    }

     CARDS = {
         SPADE => [ nil, AceOfSpades, TwoOfSpades, ThreeOfSpades, FourOfSpades, FiveOfSpades, SixOfSpades, SevenOfSpades, EightOfSpades, NineOfSpades, TenOfSpades, JackOfSpades, QueenOfSpades, KingOfSpades, AceOfSpades ],
         HEART => [ nil, AceOfHearts, TwoOfHearts, ThreeOfHearts, FourOfHearts, FiveOfHearts, SixOfHearts, SevenOfHearts, EightOfHearts, NineOfHearts, TenOfHearts, JackOfHearts, QueenOfHearts, KingOfHearts, AceOfHearts ],
       DIAMOND => [ nil, AceOfDiamonds, TwoOfDiamonds, ThreeOfDiamonds, FourOfDiamonds, FiveOfDiamonds, SixOfDiamonds, SevenOfDiamonds, EightOfDiamonds, NineOfDiamonds, TenOfDiamonds, JackOfDiamonds, QueenOfDiamonds, KingOfDiamonds, AceOfDiamonds ],
          CLUB => [ nil, AceOfClubs, TwoOfClubs, ThreeOfClubs, FourOfClubs, FiveOfClubs, SixOfClubs, SevenOfClubs, EightOfClubs, NineOfClubs, TenOfClubs, JackOfClubs, QueenOfClubs, KingOfClubs, AceOfClubs ],
         JOKER => [ Joker ],
     }

     SUIT_NAMES = {
         SPADE => 'spades'.freeze,
         HEART => 'hearts'.freeze,
       DIAMOND => 'diamonds'.freeze,
          CLUB => 'clubs'.freeze,
         JOKER => 'joker '.freeze, # The trailing space is a hack to work with SuitError as well as to_str
     }

     VALUE_NAMES = [ nil, 'ace'.freeze, 'two'.freeze, 'three'.freeze, 'four'.freeze, 'five'.freeze, 'six'.freeze, 'seven'.freeze, 'eight'.freeze, 'nine'.freeze, 'ten'.freeze, 'jack'.freeze, 'queen'.freeze, 'king'.freeze, 'ace'.freeze ]

  attr_reader :suit, :value, :s, :str, :sym, :abs
  alias :to_s :s
  alias :to_str :str
  alias :to_sym :sym
  alias :to_i :abs

  def initialize( value:, suit: )
    value = normalize_value( value )
    raise ValueError unless value.instance_of? Fixnum
    raise ValueError unless (1..14).cover? value

    suit = normalize_suit( suit )
    raise SuitError unless SUIT_NAMES.keys.include? suit

    value = 0 if suit == JOKER

    @value = value.to_i
    @suit = suit

    @s = "#{ VALUES[ value ] }#{ suit }"

    @sym = CARDS[ suit ][ value ]

    parts = [ VALUE_NAMES[ value ], SUIT_NAMES[ suit ]]
    @str = parts.compact.join( ' of ' ).strip

    @abs = ABSOLUTE_VALUE[ suit ][ value ]
    
    self.freeze
  end

private

  def normalize_value( value )
    return value if value.instance_of? Fixnum

    return VALUE_NAMES.index( value )
  end

  def normalize_suit( suit )
    return suit if SUIT_NAMES.keys.include? suit

    suit = suit.to_s
    tuple = SUIT_NAMES.find{|k,v| v.start_with? suit.to_s.downcase }
    return suit unless tuple
    tuple.first
  end

end

require 'forwardable'

class Hand

  extend Forwardable

  delegate [:map!, :[], :<<, :size, :to_a] => :@cards

  def initialize( *card_strings )
    @cards = card_strings.map do |string|
      Card.new(
        value: value = string.to_i,
        suit: string.gsub( value.to_s, '' ).to_sym,
      )
    end
  end

  def cards
    @cards
  end

  def to_s
    @cards.map(&:to_s).join(', ')
  end
end

# hand = Hand.new( '2C', '2D', '2S', '13D', '8C', '8S', '2H' )
hand = Hand.new( '2C', '2D', '2S', '13D', '8C', '8S' )
# hand = Hand.new( '2C', '2D', '2S', '13D', '8C' )

puts hand
rank = HandRank.get( hand )
p HandRank.explain( rank )

require 'benchmark'

n = 10#8000000
a = [1,2,3,4,5,6,7]
Benchmark.bm(7) do |x|
  x.report('ranking') do
    for i in 1..n
      HandRank.get(a)
    end
  end
  x.report('ranking') do
    for i in 1..n
      HandRank.rb_get(a)
    end
  end
  x.report('"s"+"s"') do
    for i in 1..n
      "Hello" + "world!"
    end
  end
end

# Test with transformation code in Ruby
#               user     system      total        real
# ranking   5.380000   0.000000   5.380000 (  5.388186)
# "s"+"s"   1.850000   0.010000   1.860000 (  1.858708)
