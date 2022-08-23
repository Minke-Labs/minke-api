class ProcessTopupJob
  include Sidekiq::Job

  def perform(uid, wallet, timestamp, source, points)
    return if Reward.where(uid: uid, source: source).any?
    
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

    Reward.transaction do
      Reward.create(uid: uid, referral_id: referral.id, source: source,
                    claimed: false, wallet: wallet, points: reward_points)
      Reward.create(uid: uid, referral_id: referral.id, source: source,
                    claimed: false, wallet: referral.referral_code.wallet,
                    points: reward_points)
    end
  end
end
