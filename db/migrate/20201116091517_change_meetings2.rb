class ChangeMeetings2 < ActiveRecord::Migration[5.2]
  def change
    rename_column :meetings, :random_num, :meeting_id
    rename_column :meetings, :start, :start_time
  end
end
