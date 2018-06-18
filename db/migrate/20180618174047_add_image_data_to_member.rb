class AddImageDataToMember < ActiveRecord::Migration[5.1]
  def change
    add_column :members, :image_data, :text
  end
end
