class RemovePlayerIdFromResultsMasters < ActiveRecord::Migration
  def change
    remove_column :results_masters, :player_id, :integer
  end
end
