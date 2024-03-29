class ProcessTopupJob
  include Sidekiq::Job

  def perform(uid, wallet, timestamp, source, points)
    return if Reward.where(uid: uid, source: source).any?

    wallet = Eth::Address.new(wallet).checksummed
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

    reward_points = [points / 2.0, Reward::MAX_POINTS].min
    referrer_points = reward_points * 0.2

    Reward.transaction do
      Reward.create(uid: uid, referral_id: referral.id, source: source,
                    claimed: false, wallet: wallet, points: reward_points)
      Reward.create(uid: uid, referral_id: referral.id, source: source,
                    claimed: false, wallet: referral.referral_code.wallet,
                    points: referrer_points)
    end
  end
end
