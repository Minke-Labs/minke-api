require 'rails_helper'

describe Reward do
  subject { described_class }
  describe '.available_for_claiming?' do
    context 'when the address does not exist' do
      it 'returns false' do
        expect(subject.available_for_claiming?('none', 100)).to be_falsey
      end
    end

    context 'with a valid address' do
      context 'with claimed rewards' do
        let!(:reward) { create(:reward, claimed: true) }

        it 'returns false' do
          expect(subject.available_for_claiming?(reward.wallet, 100)).to be_falsey
        end
      end

      context 'with not enough points' do
        let!(:reward) { create(:reward, claimed: false) }

        it 'returns false' do
          expect(subject.available_for_claiming?(reward.wallet, 101)).to be_falsey
        end
      end

      context 'with enough points' do
        let!(:reward) { create(:reward, claimed: false) }

        it 'returns false' do
          expect(subject.available_for_claiming?(reward.wallet, 100)).to be_truthy
        end
      end
    end
  end
end
