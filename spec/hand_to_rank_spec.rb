# frozen_string_literal: true

RSpec.describe HandRank do
  class << self
    def target_hands
      @target_hands ||= JSON.parse SPEC_ROOT.join('fixtures', 'hands.json').read
    end

    def combinations
      @combinations ||= target_hands.uniq { |_, v| v['combination'] }.map { |_, v| v['combination'] }
    end
  end

  combinations.each do |combination|
    context(combination) do
      context 'calculate hand_rank points from the backuped hand' do
        target_hands.select { |_, v| v['combination'] == combination }.each do |norm_points, info|
          it("should match with .rank_to_hand for #{info['hand']}") do
            new_points = HandRank.get(info['hand'].split(' ').map { |card| ranks.fetch card })
            expect(HandRank.rank_to_hand(new_points).fetch(:base_15_points)).to eq Integer(norm_points)
          end
        end
      end

      context 'calculate hand_rank ranks (regardless sorting) from the backuped hand' do
        target_hands.select { |_, v| v['combination'] == combination }.each do |_norm_points, info|
          it("should match with .rank_to_hand for #{info['hand']}") do
            new_points = HandRank.get(info['hand'].split(' ').map { |card| ranks.fetch card })
            expect(HandRank.rank_to_hand(new_points).fetch(:ranks)).to match_array info.fetch('ranks')
          end
        end
      end
    end
  end
end
