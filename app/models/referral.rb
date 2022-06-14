class Referral < ApplicationRecord
  belongs_to :referral_code

  def as_json(options)
    super({ include: :referral_code }.merge(options))
  end
end
