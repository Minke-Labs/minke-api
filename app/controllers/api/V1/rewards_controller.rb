require 'eth'

module Api
  module V1
    class RewardsController < BaseController
      def index
        @address = params[:address]
        @rewards = Reward.where(wallet: @address)
        render json: @rewards, status: :ok
      end

      def claim
        @address = params[:address]
        @points = params[:points]
        @timestamp = params[:timestamp]
        @signature = params[:signature]
        message = JSON.generate({ timestamp: @timestamp, points: @points })

        if (Eth::Signature.verify(message, @signature, @address) rescue false) &&
          @timestamp >= DateTime.now.to_i
          transfer_id = (Wyre::RewardClaim.new(@address, @points).perform rescue nil)

          if transfer_id 
            return render json: { transfer_id: transfer_id }, status: :ok
          end

          return render json: { error: 'failed_claim' }, status: :ok
        else
          return render json: { error: 'invalid_request' }, status: :ok
        end
      end
    end
  end
end
