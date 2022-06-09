class CreateReferrals < ActiveRecord::Migration[7.0]
  def change
    create_table :referrals do |t|
      t.references :referral_code, null: false, foreign_key: true, index: true
      t.string :wallet
      t.string :device_id

      t.timestamps
    end
  end
end
