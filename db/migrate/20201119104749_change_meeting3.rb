class ChangeMeeting3 < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :zoom_id, :string
    add_column :meetings, :zoom_pass, :string
    remove_column :meetings, :link, :string
  end
end
