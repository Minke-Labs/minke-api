class CreateReferralCodes < ActiveRecord::Migration[7.0]
  def change
    create_table :referral_codes do |t|
      t.string :wallet, index: true, unique: true
      t.string :device_id
      t.string :code, index: true, unique: true

      t.timestamps
    end
  end
end
