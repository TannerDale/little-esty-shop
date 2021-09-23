class AddStatsuDefault < ActiveRecord::Migration[5.2]
  def change
    change_column_default :merchants, :status, 1
  end
end
