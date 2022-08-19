class AddPointsToRewards < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :points, :integer
    add_column :rewards, :type, :string
    Reward.update_all(points: 100, type: 'TopupReward')
  end
end
