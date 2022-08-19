class ProcessTopupJob
  include Sidekiq::Job

  def perform(topup_id, destination, timestamp, source = 'wyre', points)
    return if TopupReward.where(uid: topup_id, source: source).any?

    network, wallet = destination.split(':') # "matic:0x7569c080aFBeE7A2f0017865a214E2f7A416F719"
    
    referral = Referral.includes(:referral_code)
                       .where(wallet: wallet)
                       .where('created_at < (?)', Time.at(timestamp))
                       .first
    return unless referral # referral created after the topup / exchange

    referred_points = Reward.joins(referral: :referral_code)
                            .where(wallet: wallet)
                            .where.not(referral_code: { wallet: wallet })
                            .sum(:points)

    return if referred_points > 0 # already received a reward by topping up

    reward_points = [points, Reward::MAX_POINTS].min

    TopupReward.transaction do
      TopupReward.create(uid: topup_id, referral_id: referral.id, source: source,
                         claimed: false, wallet: wallet, points: reward_points)
      TopupReward.create(uid: topup_id, referral_id: referral.id, source: source,
                         claimed: false, wallet: referral.referral_code.wallet,
                         points: reward_points)
    end
  end
end
