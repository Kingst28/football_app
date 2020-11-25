class AddReplacementToBids < ActiveRecord::Migration
  def change
    add_column :bids, :replacement, :boolean
  end
end
