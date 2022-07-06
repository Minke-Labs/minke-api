class Wyre::RewardClaim
  attr_accessor :wallet, :points
  def initialize(wallet, points)
    @wallet = wallet
    @points = points
  end

  def perform
    return unless Reward.available_for_claiming?(wallet, points)

    data = RestClient.post(url, params, headers)
    transfer = JSON.parse(data.body).dig('transfer', 'id') rescue nil

    if transfer
      Reward.where(wallet: wallet).update_all(claimed: true)
    end
    transfer
  end

  private

  def url
   'https://api.sendwyre.com/v3/transfers'
  end

  def params
    { 
      autoConfirm: true,
      source: ENV['WYRE_ACCOUNT_SOURCE'],
      sourceCurrency: "MATIC",
      sourceAmount: source_amount,
      dest: "matic:#{wallet}"
    }
  end

  def headers
    {
      Accept: 'application/json', 
      Authorization: "Bearer #{ENV['WYRE_API_KEY']}",
      'Content-Type': 'application/json', 
    }
  end

  def source_amount
    id = 'matic-network'
    url = "https://api.coingecko.com/api/v3/simple/price?ids=#{id}&vs_currencies=usd"
    data = JSON.parse(RestClient.get(url).body)
    matic_quote = data[id]['usd']
    (points * Reward::POINTS_TO_USD) / matic_quote;
  end
end
