class MoonpayTopupsCoordinatorJob
  include Sidekiq::Job
  BATCH_SIZE = 50
  SOURCE = 'moonpay'

  def perform(*args)
    offset = 0
    top_ups = search(offset)

    while top_ups.size > 0
      top_ups.each do |topup|
        topup = OpenStruct.new(topup.transform_keys { |key| key.to_s.underscore })
        next unless topup.status === 'completed'

        wallet = topup.wallet_address
        ProcessTopupJob.perform_async(topup.id, 
                                      wallet,
                                      DateTime.parse(topup.created_at).to_i,
                                      SOURCE,
                                      topup.base_currency_amount * topup.usd_rate)
      end
      offset += top_ups.size
      top_ups = search(offset)
    end
  end

  private

  def search(offset)
    Moonpay::Client.new(BATCH_SIZE, offset, start_date).search
  end

  def start_date
    @start_date ||= begin
      Reward.where(source: SOURCE).last || 1.year.ago
    end
    @start_date.to_date.to_s
  end
end
