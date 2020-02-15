class AddNewResultsReadyToAccounts < ActiveRecord::Migration
  def change
    add_column :accounts, :new_results_ready, :boolean, default: false
  end
end
