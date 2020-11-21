class ChangeMeeting4 < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :agenda_now, :int, default: 0, null: false
  end
end
