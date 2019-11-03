class AddAccountToFixtures < ActiveRecord::Migration
  def change
    add_column :fixtures, :account_id, :integer
    add_index  :fixtures, :account_id
  end
end
