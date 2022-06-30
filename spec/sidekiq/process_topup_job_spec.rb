require 'rails_helper'

describe ProcessTopupJob, type: :job do
  subject { described_class.new }

  describe '.perform' do
    context 'when the reward already exists' do
      let!(:reward) { create(:reward, uid: 1) }

      it 'does not create a reward' do
        expect { subject.perform(1, '', Time.now.to_i) }.to_not change { Reward.count }
      end
    end
    
    context 'when the reward does not exist' do
      context 'when the referral exists' do
        let(:referral) { create(:referral, created_at: 1.week.ago) }

        it 'creates a reward' do
          expect do
            subject.perform(1, "matic:#{referral.wallet}", Time.now.to_i)
          end.to change { Reward.count }.by(1)
        end

        context 'with a referral after the topup' do
          it 'does not create a reward' do
            expect do
              subject.perform(1, "matic:#{referral.wallet}", referral.created_at.to_i)
            end.to_not change { Reward.count }
          end
        end
      end

      context 'when the referral does not exist' do
        it 'does not create a reward' do
          expect do
            subject.perform(1, "matic:0xabcd", Time.now.to_i)
          end.to_not change { Reward.count }
        end
      end
    end
  end
end
