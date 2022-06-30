class CreateRewards < ActiveRecord::Migration[7.0]
  def change
    create_table :rewards do |t|
      t.string :uid
      t.references :referral, null: false, foreign_key: true
      t.boolean :claimed
      t.string :claim_uid
      t.string :source

      t.timestamps
    end
  end
end
