# frozen_string_literal: true

module HandRank
  # The main purpose of this class is to convert `absolute values` of the cards to
  # the actual low combination rank, see: `.call` method.
  #
  # Cards values can be provided in any order.
  # The method works with O(1) complexity.
  #
  # Algorithm details:
  # We replace every card rank (and we have 4 absolute values for each rank) with some prime
  # number bigger than 1. Then me multiply all this numbers (name it `internal_points`). For 1
  # hand this `internal_points` will be the same regardless the initial ordering or card suits.
  # (The substitution Hash is generated once. see: `.absolute_value_as_primitives`).
  #
  # Also, we have the Hash, where the key is `internal_points`, and the value is rank.
  # It help to get back the rank, or if the data does not match any pattern, it returns `nil`.
  # Since we have only `MAXIMUM_RANK = 56` combinations, it is not costly to store all this
  # computations in memory.
  # (see `.low_combinations`)
  class GetLo
    HAND_RANKS = %w[A 2 3 4 5 6 7 8].freeze

    # Will be used to avoid any hassle with initial cards sorting (and sorting itself)
    # we do not use primes module here, since we need only this 8 prime values
    PRIMES     = [2, 3, 5, 7, 11, 13, 17, 19].freeze

    # Amount of possible low combinations.
    MAXIMUM_RANK = 56

    # The allowable Lo hand combinations,
    # ranked from best to worst
    # Taken from https://help.replaypoker.com/hc/en-us/articles/360002231514-Omaha-Hi-Lo-
    RANKED_COMBINATIONS = [
      %w(A 2 3 4 5),
      %w(A 2 3 4 6),
      %w(A 2 3 5 6),
      %w(A 2 4 5 6),
      %w(A 3 4 5 6),
      %w(2 3 4 5 6),
      %w(A 2 3 4 7),
      %w(A 2 3 5 7),
      %w(A 2 4 5 7),
      %w(A 3 4 5 7),
      %w(2 3 4 5 7),
      %w(A 2 3 6 7),
      %w(A 2 4 6 7),
      %w(A 3 4 6 7),
      %w(2 3 4 6 7),
      %w(A 2 5 6 7),
      %w(A 3 5 6 7),
      %w(2 3 5 6 7),
      %w(A 4 5 6 7),
      %w(2 4 5 6 7),
      %w(3 4 5 6 7),
      %w(A 2 3 4 8),
      %w(A 2 3 5 8),
      %w(A 2 4 5 8),
      %w(A 3 4 5 8),
      %w(2 3 4 5 8),
      %w(A 2 3 6 8),
      %w(A 2 4 6 8),
      %w(A 3 4 6 8),
      %w(2 3 4 6 8),
      %w(A 2 5 6 8),
      %w(A 3 5 6 8),
      %w(2 3 5 6 8),
      %w(A 4 5 6 8),
      %w(2 4 5 6 8),
      %w(3 4 5 6 8),
      %w(A 2 3 7 8),
      %w(A 2 4 7 8),
      %w(A 3 4 7 8),
      %w(2 3 4 7 8),
      %w(A 2 5 7 8),
      %w(A 3 5 7 8),
      %w(2 3 5 7 8),
      %w(A 4 5 7 8),
      %w(2 4 5 7 8),
      %w(3 4 5 7 8),
      %w(A 2 6 7 8),
      %w(A 3 6 7 8),
      %w(2 3 6 7 8),
      %w(A 4 6 7 8),
      %w(2 4 6 7 8),
      %w(3 4 6 7 8),
      %w(A 5 6 7 8),
      %w(2 5 6 7 8),
      %w(3 5 6 7 8),
      %w(4 5 6 7 8),
    ]

    class << self
      # Accepts absolute cards values (or an Array of them) as an argument(s),
      # and return the rank of the low combination, where the highest rank means the best hand.
      # If the hand does not contains low, returns nil
      #
      # Returns Integer or nil
      def call(*ags)
        internal_points = ags.flatten.map { |el| absolute_value_as_primitives[el] || 1 }.inject(:*)
        low_combinations[internal_points]
      end

      # Produce the Hash, where the key is the multiplication of all hand card,
      # presented as prime values. The Value contains an `OpenStruct`, which
      # describes the hand.
      #
      # Keep in mind, that keys do not have any correlation with hand strength.
      #
      # Returns Hash[Integer]=integer
      def low_combinations
        @low_combinations ||= RANKED_COMBINATIONS.map.with_index { |combination, i| [MAXIMUM_RANK - i, combination] }
                              .each_with_object({}) do |(rank, combination), acc|
          points = combination.map { |card_rank| PRIMES[HAND_RANKS.index(card_rank)] }.inject(:*)
          acc[points] = rank
        end
      end

      # Basics on `ABSOLUTE_CARD_VALUE_LOOKUP` variable, we create a Hash, for every low
      # card where the key is a card `absolute_value` and the value is prime number.
      # This will allow to avoid sorting of the hand.
      #
      # Returns Hash
      def absolute_value_as_primitives
        return @absolute_value_as_primitives if @absolute_value_as_primitives

        prime_generator = PRIMES.each
        absolute_cards_bases = [12, 0, 1, 2, 3, 4, 5, 6]

        @absolute_value_as_primitives = absolute_cards_bases.each.with_object({}) do |e, acc|
          prime = prime_generator.next
          4.times { |i| acc[e * 4 + i + 1] = prime }
        end
      end
    end
  end

  def get_lo(*args)
    GetLo.call(*args)
  end

  module_function :get_lo
end
