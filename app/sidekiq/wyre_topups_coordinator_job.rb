class WyreTopupsCoordinatorJob
  include Sidekiq::Job
  BATCH_SIZE = 200

  def perform(*args)
    offset = 0
    top_ups = search(offset)

    while top_ups.size > 0
      top_ups.each do |topup|
        topup = OpenStruct.new(topup.transform_keys { |key| key.to_s.underscore })
        next unless topup.status === 'COMPLETE'

        _network, wallet = topup.dest&.split(':')
        ProcessTopupJob.perform_async(topup.id, 
                                      wallet,
                                      topup.created_at / 1000,
                                      'wyre',
                                      topup.usd_purchase_amount,
                                      'TopupReward')
      end
      offset += top_ups.size
      top_ups = search(offset)
    end
  end

  private

  def search(offset)
    Wyre::Client.new(BATCH_SIZE, offset).search
  end
end
