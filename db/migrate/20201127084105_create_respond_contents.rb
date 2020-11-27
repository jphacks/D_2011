class CreateRespondContents < ActiveRecord::Migration[5.2]
  def change
    create_table :respond_contents do |t|
      t.integer :respond_words_id
      t.string :content
      t.integer :duration
      t.timestamps null: false
    end
  end
end
