class CreateEntries < ActiveRecord::Migration
  def change
    create_table :entries do |t|
      t.string :word
      t.string :definition

      t.timestamps
    end
    add_index :entries, :word, unique: true
  end
end
