class AddPlayerteamToPlayerstats < ActiveRecord::Migration
  def change
    add_column :playerstats, :playerteam, :string
  end
end
