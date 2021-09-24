class Discount < ApplicationRecord
  belongs_to :merchant
  has_many :items, through: :merchant
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items

  validates :quantity, numericality: { greater_than: 0, only_integer: true }
  validates :percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100, only_integer: true }

  scope :applicable, -> {
    having('SUM(invoice_items.quantity) >= discounts.quantity')
  }

  scope :ordered_percentage, -> {
    order('discounts.percentage DESC')
  }
end
