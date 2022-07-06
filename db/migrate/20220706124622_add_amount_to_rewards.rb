class AddAmountToRewards < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :amount, :float
  end
end
