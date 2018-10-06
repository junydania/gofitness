class AddIndexEmailToMember < ActiveRecord::Migration[5.1]
  def change
    add_index :members, :email
  end

end
