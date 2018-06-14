class AddFanIdToMemos < ActiveRecord::Migration[5.2]
  def change
    remove_foreign_key :fans, column: :memo_id
    remove_column :fans, :memo_id
    add_reference :memos, :fan, foreign_key: true
  end
end
