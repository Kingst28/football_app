class RemoveReplacementFromBids < ActiveRecord::Migration
  def change
    remove_column :bids, :replacement, :boolean
  end
end
