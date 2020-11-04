class CreateMeetings < ActiveRecord::Migration[5.2]
  def change
    create_table :meetings do |t|
      t.integer :random_num
      t.integer :start
      t.string :link
      t.string :image
      t.timestamps null: false
    end
  end
end
