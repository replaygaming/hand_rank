# WIP

Please read this entire readme before using the gem, thank you.

[![Gem Version](https://badge.fury.io/rb/hand_rank.svg)](http://badge.fury.io/rb/hand_rank)
[![Code Climate](https://codeclimate.com/github/replaygaming/hand_rank/badges/gpa.svg)](https://codeclimate.com/github/replaygaming/hand_rank)
[![Test Coverage](https://codeclimate.com/github/replaygaming/hand_rank/badges/coverage.svg)](https://codeclimate.com/github/replaygaming/hand_rank/coverage)
[![Build Status          ][travisci_badge]][travisci]



# HandRank

The hand_rank gem is a Ruby, with C extension, implementation of the Two Plus Two
hand evaluation algorithm for Texam Hold'em hands (or any hands following the
same ranking order).

The algorithm uses a large, 130+MB, lookup table and ranks a hand 5-7 card hand
by doing 5-7 jumps in hte table and landing on the cell that represents the hand
you walked to get there, regardless of the order of the steps.

Each, final, cell contains the Cactus Kev hands equivalence number, a number
describing the hand among every possible hand. This number can then be compared
to any other hands equivalence number to see who is the winner.

The Plus Two version also reorders the equivalence classes to allow for getting
a rank within a category. So you can split the rank into a category and a rank
within that category.

## Refrence

For some not so light reading on the subject I suggest you check out the
original sources for all the pieces as well as a comparison roundup from, the
now defunct, codingthewheel site:

[Cactus Kev's original Poker Hand Evaluator](http://suffe.cool/poker/evaluator.html)
describes the ordering of hands in the lookup table and the concept of the hand
equivalence classes.

[Paul Senzee - "Some Perfect Hash"](http://www.paulsenzee.com/2006/06/some-perfect-hash.html)
describes a hashing algorithm to improve on the size of the Cactus Kev lookup
table and is the same that is used for the lookup table to the Two Plus Two solution.

[The original thread on the Two Plus Two forums]() where it all came together. It's
long and threatens to become a bit flamy at times. But in the end I think it is
a great example of what you can accomplich on the internet, with strangers if
you are all prepared to act for the greater good.

And finally [the poker evaluator roundup from codingthewheel.com](http://web.archive.org/web/20150113024316/http://codingthewheel.com/archives/poker-hand-evaluator-roundup) unfortunately via the
waybackmachine since the original site is no longer live :/ Great roundup, with
code, of all the relevant approaches. The code from the roundup is still
[available on Github](https://github.com/christophschmalhofer/poker/tree/master/XPokerEval)
so there is that ...

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'hand_rank'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install hand_rank

## Usage
### Hand and card format
To create a hand you need the cards absolute values. You somehow have to convert
your representation of a hand into an array of integers where each integer
represents a card following this encoding:

```ruby
ABSOLUTE_CARD_VALUE_LOOKUP = {
  #       spacer,  A,  2,  3,  4,  5,  6,  7,  8,  9, 10,  J,  Q,  K,  A
     club: [ nil, 49,  1,  5,  9, 13, 17, 21, 25, 29, 33, 37, 41, 45, 49 ],
  diamond: [ nil, 50,  2,  6, 10, 14, 18, 22, 26, 30, 34, 38, 42, 46, 50 ],
    heart: [ nil, 51,  3,  7, 11, 15, 19, 23, 27, 31, 35, 39, 43, 47, 51 ],
    spade: [ nil, 52,  4,  8, 12, 16, 20, 24, 28, 32, 36, 40, 44, 48, 52 ],
}
```

This table allows you to lookup and card by suit and value (from 1 to 14,
allowing for both high and low aces). In our implementation the `Card` class has
an `abs`method and the `Hand` class impersonates an array. Since this gem will
actually run `map!(&:abs)` on the input before handing it off to the C code our
setup allows us to give it a real `Hand` and just leave it to the magic to
transform that into an array of integers.

It will still work fine if you feed it an array of integers though. Arrays
respond to `map` and fixnum responds to `abs` so it is golden either way.

### Operations

```ruby
# A hand of     AH  KH  9D  4C  JS  QD  10H
cards_array = [ 51, 47, 30,  9, 40, 42, 35 ]

rank = HandRank.get( cards_array )
# 20490

categories = [
  "invalid_hand",
  "high_card",
  "one_pair",
  "two_pairs",
  "three_of_a_kind",
  "straight",
  "flush",
  "full_house",
  "four_of_a_kind",
  "straight_flush"
]

HandRank.category( rank )
# 5

HandRank.rank_in_category( rank )
# 10

HandRank.category_key( rank )
# "straight"

puts HandRank.explain( rank )
# => The hand is a straight
#    Rank: 20490 Category: 5 Rank in category: 10
```

#### Get low combination rank

```
require 'hand_rank/get_lo'

# ["As", "6d", "2c", "5d", "4c"]
HandRank.get_lo([52, 18, 1, 14, 9]) # => 46
```

Keep in mind, that the best combination is 56th and the worst is 1.

#### Rank to hand (optional)

```ruby
require 'hand_rank/rank_to_hand'

HandRank.rank_to_hand 20490
# => {:combination=>"straight", :ranks=>["T", "A"], :hand=>["T", "J", "Q", "K", "A"], :base_15_points=>3795500}
```

Under the hood, this is a huge static hash. The content of this Hash were generated by
`bin/generate` script and does not require any manual manipulations.

Keep in mind, that hands are always sorted from left to right.

## Timing
Some simple timing might be in order.

```ruby
require 'benchmark'

n = 8000000
a = [1,2,3,4,5,6,7]
Benchmark.bm(7) do |x|
  x.report('ranking') do
    for i in 1..n
      HandRank.get(a)
    end
  end
  x.report('"s"+"s"') do
    for i in 1..n
      "Hello" + "world!"
    end
  end
end
```

Running on a 2015 MacBook pro gives these results:

```
              user     system      total        real
ranking   0.900000   0.000000   0.900000 (  0.907518)
"s"+"s"   1.850000   0.000000   1.850000 (  1.856820)
```

So ranking a hand is about twice as fast as a string concatenation. On the test
machine it can rank over 8 million hands a second, that is one hand every 8 or
so microseconds.

## Contributing

1. Fork it ( https://github.com/[my-github-username]/hand_rank/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

[travisci_badge]: https://travis-ci.org/replaygaming/hand_rank.svg?branch=master
[travisci]: https://travis-ci.org/replaygaming/hand_rank
