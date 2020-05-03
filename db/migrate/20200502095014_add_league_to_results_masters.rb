class AddLeagueToResultsMasters < ActiveRecord::Migration
  def change
    add_column :results_masters, :league, :string
  end
end
