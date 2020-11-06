class ChangeMeetings < ActiveRecord::Migration[5.2]
  def change
    change_column :meetings, :random_num, :string
  end
end
