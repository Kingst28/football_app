class AddAccountToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :account_id, :integer
    add_index  :players, :account_id
  end
end
