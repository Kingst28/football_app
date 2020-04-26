class AddNameToResultsMasters < ActiveRecord::Migration
  def change
    add_column :results_masters, :name, :string
  end
end
