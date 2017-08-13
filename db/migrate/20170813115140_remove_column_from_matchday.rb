class RemoveColumnFromMatchday < ActiveRecord::Migration
  def change
    remove_column :matchdays, :integer, :string
  end
end
