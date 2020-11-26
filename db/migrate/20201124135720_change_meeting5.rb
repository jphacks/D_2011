class ChangeMeeting5 < ActiveRecord::Migration[5.2]
  def change
    add_column :meetings, :email, :string
  end
end
