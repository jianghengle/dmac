class AddFileFilterToChannel < ActiveRecord::Migration[5.0]
  def change
  	add_column :channels, :file_filter, :string
  end
end
