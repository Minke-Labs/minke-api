class AddWalletToReward < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :wallet, :string
  end
end
