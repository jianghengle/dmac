class CreateDownloads < ActiveRecord::Migration[5.0]
  def change
    create_table :downloads do |t|
      t.string :key
      t.string :project_key
      t.string :data_path

      t.timestamps
    end

    add_index :downloads, :key
  end
end
