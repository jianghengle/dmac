class CreateChannels < ActiveRecord::Migration[5.0]
  def change
    create_table :channels do |t|
      t.references :project, foreign_key: true
      t.string :path
      t.string :meta_data
      t.text :instruction
      t.boolean :rename

      t.timestamps
    end
  end
end
