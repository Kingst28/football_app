class AddAccountToLeagueTables < ActiveRecord::Migration
  def change
    add_column :league_tables, :account_id, :integer
    add_index  :league_tables, :account_id
  end
end
