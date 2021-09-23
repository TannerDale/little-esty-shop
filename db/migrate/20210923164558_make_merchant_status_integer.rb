class MakeMerchantStatusInteger < ActiveRecord::Migration[5.2]
  def change
    remove_column :merchants, :status
  end
end
