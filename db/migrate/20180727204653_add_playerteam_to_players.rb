class AddPlayerteamToPlayers < ActiveRecord::Migration
  def change
    add_column :players, :playerteam, :string
  end
end
