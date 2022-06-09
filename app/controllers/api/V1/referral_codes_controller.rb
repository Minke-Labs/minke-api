module Api
  module V1
    class ReferralCodesController < BaseController
      def create
        @referral_code = ReferralCode.find_or_create_by(wallet: params[:wallet]) do |code|
          code.device_id = referral_code_params[:device_id]
        end

        render json: @referral_code, status: :ok
      end

      private

      def referral_code_params
        params.permit(:device_id)
      end
    end
  end
end
