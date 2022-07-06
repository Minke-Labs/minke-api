
require 'rails_helper'

describe Api::V1::ReferralCodesController, type: :request do
  include_context 'authentication'

  describe '#create' do
    context 'with invalid params' do
      it 'does not create a code' do 
        expect do
          post api_v1_referral_codes_path, params: {}, headers: authentication_header
        end.to_not change { ReferralCode.count }
      end
    end

    context 'with valid params' do
      context 'with a new wallet' do
        let(:wallet) { '0x1234' }
        let(:device_id) { 'iphone_123' }

        it 'creates a new referral code' do
          post api_v1_referral_codes_path,
            params: { wallet: wallet, device_id: device_id },
            headers: authentication_header

          expect(response).to be_successful
          expect(json_body['device_id']).to eq(device_id)
          expect(json_body['wallet']).to eq(wallet)
          expect(json_body['id']).to_not be_nil
          expect(json_body['code']).to_not be_nil
          expect(json_body['code'].size).to eq(6)
        end
      end
    end
  end
end
