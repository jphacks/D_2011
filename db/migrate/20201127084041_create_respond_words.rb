class CreateRespondWords < ActiveRecord::Migration[5.2]
  def change
    create_table :respond_words do |t|
      t.string :word
      t.timestamps null: false
    end
  end
end
