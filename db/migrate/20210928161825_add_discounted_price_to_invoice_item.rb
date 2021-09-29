class AddDiscountedPriceToInvoiceItem < ActiveRecord::Migration[5.2]
  def change
    add_column :invoice_items, :discounted_price, :integer
  end
end
