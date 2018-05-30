class ChangeMemosContentDefaultValue < ActiveRecord::Migration[5.2]
  def change
    change_column_default(:memos, :content, '')
  end
end
