module Api
  module V1
    class ReferralsController < BaseController
      def create
        @referral_code = ReferralCode.find_by(code: params[:code])

        unless @referral_code.present? &&
          referral_params[:device_id].present? &&
          referral_params[:wallet].present? &&
          @referral_code.wallet != referral_params[:wallet]
          return render json: { error: 'invalid_code' }, status: :ok
        end

        device_wallets = ReferralCode.where(device_id: referral_params[:device_id])
                                     .where.not(wallet:referral_params[:wallet]).pluck(:wallet)
        if device_wallets.include?(referral_params[:wallet])
          return render json: { error: 'invalid_code' }, status: :ok
        end

        @referral = Referral.find_or_create_by(wallet: referral_params[:wallet]) do |ref|
          ref.device_id = referral_params[:device_id]
          ref.referral_code = @referral_code
        end

        if @referral
          render json: @referral, status: :ok
        else
          render json: @referral.errors, status: :unprocessable_entity
        end
      end

      def show
        @referral = Referral.includes(:referral_code).find_by(wallet: params[:id])

        if @referral
          render json: @referral.referral_code, status: :ok
        else
          render json: {}, status: :ok
        end
      end

      private

      def referral_params
        params.permit(:wallet, :device_id)
      end
    end
  end
end
