class CreateSynonyms < ActiveRecord::Migration[5.1]
  def change
    create_table :synonyms do |t|
      t.string :word
      t.string :words, :array => true, :default => []

      t.timestamps
    end
  end
end
