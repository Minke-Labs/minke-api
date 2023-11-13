class ExchangeCoordinatorJob
  include Sidekiq::Job
  STABLECOINS = ['USDC', 'USDT', 'DAI']

  def perform(*args)
    exchanges.each do |exchange|
      exchange = OpenStruct.new(exchange.transform_keys { |key| key.to_s.underscore })
      next unless reward_available?(exchange)

      ProcessTopupJob.perform_async(exchange.hash, 
                                    exchange.destination,
                                    exchange.time_stamp.to_i,
                                    'exchange',
                                    exchange.amount.to_i)
    end
  end

  private

  def reward_available?(exchange)
    exchange.tx_successful &&
    STABLECOINS.include?(exchange.symbol) &&
    exchange.time_stamp.to_i >= [last_reward_date, default_timestamp].max
  end

  def last_reward_date
    @last_reward_date ||= Reward.where(source: 'exchange').last&.created_at.to_i
  end

  def default_timestamp
    1661252295
  end

  def exchanges
    @exchanges ||= Zapper::Client.new.search
  end
end
