class AddTeamsToPlayers < ActiveRecord::Migration
  def change
    add_reference :players, :teams, index: true
  end
end
