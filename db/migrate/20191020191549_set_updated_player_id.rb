class SetUpdatedPlayerId < ActiveRecord::Migration
  def change
    Player.find_each do |player|
    ResultsMaster.create(:player_id => player.id)
end
end
end
