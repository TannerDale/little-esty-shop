class Item < ApplicationRecord
  self.primary_key = :id

  belongs_to :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
end
