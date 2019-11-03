class AddAccountToTeams < ActiveRecord::Migration
  def change
    add_column :teams, :account_id, :integer
    add_index  :teams, :account_id
  end
end
