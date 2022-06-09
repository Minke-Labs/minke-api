class ReferralCode < ApplicationRecord
  before_create :set_code!

  protected
  def set_code!
    return if code.present?

    new_code = SecureRandom.hex.first(6).upcase
    new_code = SecureRandom.hex.first(6).upcase while ReferralCode.where(code: new_code).exists?
    self.code = new_code
  end
end
