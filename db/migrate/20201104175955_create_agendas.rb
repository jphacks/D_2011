class CreateAgendas < ActiveRecord::Migration[5.2]
  def change
    create_table :agendas do |t|
      t.integer :meeting_id
      t.string :title
      t.integer :duration
      t.string :sentence
      t.timestamps null: false
    end
  end
end
