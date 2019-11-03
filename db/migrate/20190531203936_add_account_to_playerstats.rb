class AddAccountToPlayerstats < ActiveRecord::Migration
  def change
    add_column :playerstats, :account_id, :integer
    add_index  :playerstats, :account_id
  end
end
