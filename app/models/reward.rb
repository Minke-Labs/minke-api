class Reward < ApplicationRecord
  belongs_to :referral

  POINTS_PER_REWARD = 100
  POINTS_TO_USD = 0.1

  def as_json(options)
    super({ include: :referral, methods: [:timestamp] }.merge(options))
  end

  def self.available_for_claiming?(address, points)
    (Reward.where(wallet: address, claimed: false).count * POINTS_PER_REWARD) >= points
  end

  def timestamp
    created_at.to_i
  end
end
