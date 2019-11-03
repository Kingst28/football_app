class AddAccountToTeamsheets < ActiveRecord::Migration
  def change
    add_column :teamsheets, :account_id, :integer
    add_index  :teamsheets, :account_id
  end
end
