
require 'rails_helper'

describe Api::V1::ReferralCodesController, type: :request do
  let(:api_user) { FactoryBot.create(:api_user) }
  describe '#create' do
    context 'with the authorization header' do
      it 'authenticates' do
        post api_v1_referral_codes_path
        expect(response).to_not be_successful
        expect(response.body).to include('HTTP Token: Access denied')
      end
    end
  end
end
