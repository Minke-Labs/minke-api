module Api
  module V1
    class DisabledWalletController < ApplicationController
      def index
        enabled = ActiveRecord::Type::Boolean.new.cast(Redis.current.get('wallet_enabled')) || false
        render json: { enabled: enabled }, status: :ok
      end
    end
  end
end
