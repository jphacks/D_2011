class ChangeMeeting6 < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :join, :boolean, default: false, null: false
  end
end
