class AddMemberReferenceToPauseHistory < ActiveRecord::Migration[5.1]
  def change
    add_reference :pause_histories, :member, index: true
  end
end
