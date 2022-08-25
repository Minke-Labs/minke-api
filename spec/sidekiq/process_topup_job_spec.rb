require 'rails_helper'

describe ProcessTopupJob, type: :job do
  subject { described_class.new }

  describe '.perform' do
    context 'when the reward already exists' do
      context 'with a topup reward' do
        let!(:reward) { create(:reward, uid: 1) }

        it 'does not create a reward' do
          expect do
            subject.perform(1, '', Time.now.to_i, reward.source, 100)
          end.to_not change { Reward.count }
        end
      end

      context 'with an exchange reward' do
        let!(:reward) { create(:reward, uid: 1, source: 'exchange') }

        it 'does not create a reward' do
          expect do
            subject.perform(1, '', Time.now.to_i, 'exchange', 100)
          end.to_not change { Reward.count }
        end
      end
    end
    
    context 'when the reward does not exist' do
      context 'when the referral exists' do
        let(:referral) { create(:referral, created_at: 1.week.ago) }

        context 'with a topup reward' do
          it 'creates two rewards' do
            expect do
              subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 100)
            end.to change { Reward.count }.by(2)
          end

          it 'creates the correct rewards' do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 100)
            expect(Reward.where(wallet: [referral.wallet, referral.referral_code.wallet]).count).to eq(2)
          end

          context 'with a bad formatted wallet' do
            it 'creates two rewards' do
              expect do
                subject.perform(1, referral.wallet.downcase, Time.now.to_i, 'wyre', 100)
              end.to change { Reward.count }.by(2)
            end
          end
        end

        context 'with an exchange reward' do
          it 'creates two rewards' do
            expect do
              subject.perform(1, referral.wallet, Time.now.to_i, 'exchange', 100)
            end.to change { Reward.count }.by(2)
          end

          it 'creates the correct rewards' do
            subject.perform(1, referral.wallet, Time.now.to_i, 'exchange', 100)
            expect(Reward.where(wallet: [referral.wallet, referral.referral_code.wallet]).count).to eq(2)
          end
        end

        context 'with a referral after the topup' do
          it 'does not create a reward' do
            expect do
              subject.perform(1, referral.wallet, referral.created_at.to_i, 'wyre', 100)
            end.to_not change { Reward.count }
          end
        end

        context 'with less points than the maximum' do
          it 'gives the right amount of points' do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 40)
            points = Reward.where(wallet: [referral.wallet, referral.referral_code.wallet]).pluck(:points)
            expect(points).to eq([40,40])
          end
        end

        context 'with more points than the maximum' do
          it 'gives the maximum amount of points' do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 800)
            points = Reward.where(wallet: [referral.wallet, referral.referral_code.wallet]).pluck(:points)
            expect(points).to eq([100,100])
          end
        end
      end

      context 'when the referral does not exist' do
        it 'does not create a reward' do
          expect do
            subject.perform(1, Faker::Blockchain::Ethereum.address, Time.now.to_i, 'wyre', 100)
          end.to_not change { Reward.count }
        end
      end
    end

    context 'when the referred already has a reward' do
      let(:referral) { create(:referral, created_at: 1.week.ago) }

      context 'with a topup reward' do
        it 'does not give another reward' do
          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 100)
          end.to change { Reward.count }.by(2)

          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 100)
          end.to_not change { Reward.count }
        end
      end

      context 'with an exchange reward' do
        it 'does not give another reward' do
          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'exchange', 100)
          end.to change { Reward.count }.by(2)

          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'exchange', 100)
          end.to_not change { Reward.count }
        end
      end
    end

    context 'when the referral already has a reward' do
      let(:referral) { create(:referral, created_at: 1.week.ago) }
      let(:another) { create(:referral, referral_code: referral.referral_code, created_at: 1.week.ago) }

      context 'with a topup reward' do
        it 'gives another reward' do
          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'wyre', 100)
          end.to change { Reward.count }.by(2)

          expect do
            subject.perform(2, another.wallet, Time.now.to_i, 'wyre', 100)
          end.to change { Reward.count }.by(2)
        end
      end

      context 'with an exchange reward' do
        it 'gives another reward' do
          expect do
            subject.perform(1, referral.wallet, Time.now.to_i, 'exchange', 100)
          end.to change { Reward.count }.by(2)

          expect do
            subject.perform(2, another.wallet, Time.now.to_i, 'exchange', 100)
          end.to change { Reward.count }.by(2)
        end
      end
    end
  end
end
