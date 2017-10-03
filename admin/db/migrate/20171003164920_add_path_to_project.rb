class AddPathToProject < ActiveRecord::Migration[5.0]
  def change
  	add_column :projects, :path, :string
  end
end
