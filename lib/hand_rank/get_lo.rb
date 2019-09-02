# frozen_string_literal: true

module HandRank
  class GetLo
    HAND_RANKS = %w[A 2 3 4 5 6 7 8].freeze

    # Will be used to avoid any hassle with initial cards sorting (and sorting itself)
    # we do not use primes module here, since we need only this 8 prime values
    PRIMES     = [2, 3, 5, 7, 11, 13, 17, 19].freeze

    # Amount of possible low combinations.
    MAXIMUM_RANK = 56

    class << self
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
      # Returns Hash[Integer]=OpenStruct
      def low_combinations
        @low_combinations ||= HAND_RANKS
                              .combination(5).map.with_index { |el, i| [MAXIMUM_RANK - i, el] }
                              .each_with_object({}) do |(rank, combination), acc|
          points = combination.map { |card_rank| PRIMES[HAND_RANKS.index(card_rank)] }.inject(:*)
          acc[points] = rank
        end
      end

      # Basics on `ABSOLUTE_CARD_VALUE_LOOKUP` variable, we create a Hash, for every low
      # card where the key is a card `absolute_value` and the value is prime number.
      # This will allow to avoid sorting of the hand.
      #
      # Return Hash
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
