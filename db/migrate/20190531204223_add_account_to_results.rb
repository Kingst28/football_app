class AddAccountToResults < ActiveRecord::Migration
  def change
    add_column :results, :account_id, :integer
    add_index  :results, :account_id
  end
end
