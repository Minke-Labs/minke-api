require 'rails_helper'

describe Api::V1::ReferralsController, type: :request do
  include_context 'authentication'

  describe '#create' do
    context 'without an existing referral code' do
      it 'returns an error' do
        post api_v1_referrals_path,
          params: { code: 'inexisting' },
          headers: authentication_header
  
          expect(response).to be_successful
          expect(response.body).to eq({ error: 'invalid_code'}.to_json)
      end
    end

    context 'with an existing referral code' do
      let(:referral) { FactoryBot.create(:referral) }
      context 'without a wallet' do
        it 'returns an error' do
          post api_v1_referrals_path,
            params: { code: referral.referral_code.code, device_id: 'id' },
            headers: authentication_header
    
            expect(response).to be_successful
            expect(response.body).to eq({ error: 'invalid_code'}.to_json)
        end
      end

      context 'without a device id' do
        it 'returns an error' do
          post api_v1_referrals_path,
          params: { code: referral.referral_code.code, wallet: 'wallet' },
          headers: authentication_header

          expect(response).to be_successful
          expect(response.body).to eq({ error: 'invalid_code'}.to_json)
        end
      end

      context 'from the same wallet' do
        it 'returns an error' do
          post api_v1_referrals_path,
          params: { code: referral.referral_code.code,
                    device_id: 'abc',
                    wallet: referral.referral_code.wallet },
          headers: authentication_header

          expect(response).to be_successful
          expect(response.body).to eq({ error: 'invalid_code'}.to_json)
        end
      end

      context 'from a wallet from the same device' do
        let!(:previous_code) { FactoryBot.create(:referral_code, device_id: referral.device_id) }

        it 'returns an error' do
          post api_v1_referrals_path,
          params: { code: referral.referral_code.code,
                    device_id: referral.device_id,
                    wallet: previous_code.wallet },
          headers: authentication_header

          expect(response).to be_successful
          expect(response.body).to eq({ error: 'invalid_code'}.to_json)
        end
      end


      context 'from another wallet and device' do
        context 'when the wallet already has a referral' do
          it 'returns the existing referral' do
            post api_v1_referrals_path,
              params: { code: referral.referral_code.code,
                        device_id: referral.device_id,
                        wallet: referral.wallet },
              headers: authentication_header

            expect(response).to be_successful
            expect(response.body).to eq(referral.to_json)
          end
        end

        context 'when the wallet does not have a referral' do
          it 'creates a new referral' do
            post api_v1_referrals_path,
              params: { code: referral.referral_code.code,
                        device_id: 'another_device_id',
                        wallet: 'another_wallet' },
              headers: authentication_header

            expect(response).to be_successful
            expect(json_body['device_id']).to eq('another_device_id')
            expect(json_body['wallet']).to eq('another_wallet')
          end
        end
      end
    end
  end

  describe '#show' do
    context 'when the wallet has a referral' do
      let(:referral) { FactoryBot.create(:referral) }

      it 'returns the referral code as JSON' do
        get api_v1_referral_path(id: referral.wallet), headers: authentication_header
        expect(response).to be_successful
        expect(response.body).to eq(referral.referral_code.to_json)
      end
    end

    context 'when the wallet does not have a referral' do
      it 'returns an empty JSON' do
        get api_v1_referral_path(id: 'inexisting'), headers: authentication_header
        expect(response).to be_successful
        expect(json_body).to eq({})
      end
    end
  end
end
