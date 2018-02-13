class AddNameToChannel < ActiveRecord::Migration[5.0]
  def change
  	add_column :channels, :name, :string
  end
end
