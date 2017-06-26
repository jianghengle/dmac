class AddGroupToControl < ActiveRecord::Migration[5.0]
  def change
  	add_column :controls, :group, :string
  end
end
