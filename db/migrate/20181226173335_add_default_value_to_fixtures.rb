class AddDefaultValueToFixtures < ActiveRecord::Migration
  def change
  	 change_column :fixtures, :finalscore, :string, :default => ""
  end
end
