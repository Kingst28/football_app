class AddDefaultToTaken < ActiveRecord::Migration
  def change
    change_column :players, :taken, :string, :default => "No"
  end
end
