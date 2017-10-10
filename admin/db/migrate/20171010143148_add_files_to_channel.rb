class AddFilesToChannel < ActiveRecord::Migration[5.0]
  def change
  	add_column :channels, :files, :integer
  end
end
