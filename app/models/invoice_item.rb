# frozen_string_literal: true

class InvoiceItem < ApplicationRecord
  self.primary_key = :id

  belongs_to :invoice
  belongs_to :item
  has_one :merchant, through: :item
  has_many :discounts, through: :merchant
  has_many :transactions, through: :invoice

  validates_presence_of :status

  enum status: %w[pending packaged shipped]

  scope :not_shipped, -> {
    where.not(status: 2)
  }

  scope :revenue, -> {
    sum('unit_price * quantity')
  }

  scope :discounted, -> {
    quantities
      .joins(:transactions, :discounts)
      .group('discounts.id, invoice_items.item_id')
      .select('discounts.*, invoice_items.item_id AS discount_item')
      .merge(Transaction.success)
      .merge(Discount.applicable)
      .merge(Discount.ordered_percentage)
  }

  scope :quantities, -> {
    select('SUM(invoice_items.quantity) AS amount')
  }
end
