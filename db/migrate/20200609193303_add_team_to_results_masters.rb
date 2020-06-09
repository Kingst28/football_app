class AddTeamToResultsMasters < ActiveRecord::Migration
  def change
    add_column :results_masters, :team, :string
  end
end
