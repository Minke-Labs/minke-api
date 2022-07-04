class ProcessTopupJob
  include Sidekiq::Job

  def perform(topup_id, destination, timestamp, source = 'wyre')
    return if Reward.where(uid: topup_id, source: source).any?

    network, wallet = destination.split(':') # "matic:0x7569c080aFBeE7A2f0017865a214E2f7A416F719"
    
    referral = Referral.includes(:referral_code)
                       .where(wallet: wallet)
                       .where('created_at < (?)', Time.at(timestamp))
                       .first
    return unless referral

    return if Reward.joins(referral: :referral_code)
                    .where(wallet: wallet)
                    .where.not(referral_code: { wallet: wallet })
                    .any?

    Reward.transaction do
      Reward.create(uid: topup_id, referral_id: referral.id, source: source,
                    claimed: false, wallet: wallet)
      Reward.create(uid: topup_id, referral_id: referral.id, source: source,
                    claimed: false, wallet: referral.referral_code.wallet)
    end
  end
end
