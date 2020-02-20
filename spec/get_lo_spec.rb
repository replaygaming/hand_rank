# frozen_string_literal: true

require 'hand_rank/get_lo'

RSpec.describe HandRank::GetLo do
  def self.as_absolute_values(*args)
    args.flatten.map{|card| ranks[card] }
  end

  def as_absolute_values(*args)
    self.class.as_absolute_values(*args)
  end


  describe '.absolute_value_as_primitives' do
    it { expect(described_class.absolute_value_as_primitives).to be_a Hash }
    it { expect(described_class.absolute_value_as_primitives[1]).to eq 3 }
    it { expect(described_class.absolute_value_as_primitives[2]).to eq 3 }
    it { expect(described_class.absolute_value_as_primitives[3]).to eq 3 }
    it { expect(described_class.absolute_value_as_primitives[4]).to eq 3 }
    it { expect(described_class.absolute_value_as_primitives[5]).to eq 5 }

    it { expect(described_class.absolute_value_as_primitives[28]).to eq 19 }
    it { expect(described_class.absolute_value_as_primitives[29]).to be_nil }
    it { expect(described_class.absolute_value_as_primitives[48]).to be_nil }
    it { expect(described_class.absolute_value_as_primitives[49]).to eq 2 }
    it { expect(described_class.absolute_value_as_primitives[52]).to eq 2 }
  end

  describe '.low_combinations' do
    it { expect(described_class.low_combinations).to be_a Hash }
    it { expect(described_class.low_combinations.keys).to all(be_a_kind_of(Integer)) }
    it { expect(described_class.low_combinations.values).to all(be_a_kind_of(Integer)) }
  end

  describe '.call' do
    it('with out cards') { expect(described_class.call).to be_nil }
    it('with out low card') { expect(described_class.call(39)).to be_nil }
    it('with doubled card rank') { expect(described_class.call(as_absolute_values(%w[As Ad 2c 5d 4c]))).to be_nil }

    context 'cards order does not matter with out low' do
      cards = as_absolute_values(%w[As Ad 2c 5d 4c])
      cards.permutation.each do |combination|
        it("with doubled card rank, as combination absolute cards values #{combination.inspect} returns nil") do
          expect(described_class.call(combination)).to be_nil
        end
      end
    end

    context 'cards order does not matter with low' do
      cards = as_absolute_values(%w[As 6d 2c 5d 4c])
      cards.permutation.each do |combination|
        it("with doubled card rank, as combination absolute cards values #{combination.inspect} returns OpenStruct") do
          expect(described_class.call(combination)).to eq 53
        end
      end
    end

    [
        { cards: %w[As 6d 2c 5d 4c], rank: 53 },
        { cards: %w[As 3d 4c 5d 2c], rank: 56 },
        { cards: %w[As 3d 4c 6d 2c], rank: 55 },
        { cards: %w[7s 3d 4c 6d 2c], rank: 42 },
        { cards: %w[7s 3d 8c 6d 2c], rank: 8 },
        { cards: %w[7s 5d 8c 6d 4c], rank: 1 },
    ].each do |condition|
      it("detects the combination #{condition[:cards]}") do
        expect(described_class.call(as_absolute_values(condition[:cards]))).to eq condition[:rank]
      end
    end
  end
end
