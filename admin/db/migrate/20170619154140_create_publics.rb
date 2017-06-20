class CreatePublics < ActiveRecord::Migration[5.0]
  def change
    create_table :publics do |t|
    	t.string :key
      	t.references :project, foreign_key: true
      	t.string :data_path
      	t.string :path

      	t.timestamps
    end

    add_index :publics, :key, unique: true
    add_index :publics, :path
  end
end
