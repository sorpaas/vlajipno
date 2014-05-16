class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :name
      t.text :description
      t.text :content

      t.timestamps
    end
    
    add_index :documents, :name, unique: true
  end
end
