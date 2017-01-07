class AddAcceptedTosToUsers < ActiveRecord::Migration
  def change
    add_column :users, :accepted_tos, :boolean, default: false
  end
end
