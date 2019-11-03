class AddAccountToMatchdays < ActiveRecord::Migration
  def change
    add_column :matchdays, :account_id, :integer
    add_index  :matchdays, :account_id
  end
end
