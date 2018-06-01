class ChangeMemoStringToText < ActiveRecord::Migration[5.2]
  def change
    change_column :memos, :content, :text
  end
end
