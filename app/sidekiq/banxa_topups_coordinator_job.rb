class BanxaTopupsCoordinatorJob
  include Sidekiq::Job
  BATCH_SIZE = 100

  def perform(*args)
    page = 1
    last_reward = Reward.where(source: 'banxa').last
    start_date = last_reward ? last_reward.created_at.to_date.to_s : '2022-08-18'
    end_date =  Date.today.to_s
    top_ups = search(page, start_date, end_date)

    while top_ups.size > 0
      top_ups.each do |topup|
        topup = OpenStruct.new(topup)
        next unless topup.order_type === 'CRYPTO-BUY' && topup.coin_code === 'USDC'

        ProcessTopupJob.perform_async(topup.id, 
                                      topup.wallet_address,
                                      DateTime.parse(topup.completed_at).to_i,
                                      'banxa',
                                      topup.coin_amount,
                                      'TopupReward')
      end
      page += 1
      top_ups = search(page, start_date, end_date)
    end
  end

  private

  def search(page, start_date, end_date)
    Banxa::Client.new(limit: BATCH_SIZE, page: page, start_date: start_date, end_date: end_date).search
  end
end
