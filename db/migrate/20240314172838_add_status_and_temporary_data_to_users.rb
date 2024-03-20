class AddStatusAndTemporaryDataToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :status, :string
    add_column :users, :temporary_data, :text
  end
end
