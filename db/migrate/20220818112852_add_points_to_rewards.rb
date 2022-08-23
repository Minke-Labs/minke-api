class AddPointsToRewards < ActiveRecord::Migration[7.0]
  def change
    add_column :rewards, :points, :integer
    Reward.update_all(points: 100)
  end
end
