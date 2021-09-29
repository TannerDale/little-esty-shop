# frozen_string_literal: true

class InvoiceItem < ApplicationRecord
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

  scope :applicable_discounts, -> {
    joins(item: :discounts)
      .where('invoice_items.quantity >= discounts.quantity')
      .select('discounts.id AS discount, discounts.percentage AS percentage, invoice_items.*')
      .order(percentage: :desc)
  }

  def revenue
    unit_price * quantity
  end

  def amount_off
    discounts
      .having('quantity >= discounts.quantity')
      .select('MAX(discounts.percentage) AS discounted')
      .group(:id, :unit_price)
  end

  def lock_discounted_price
    new_price = (unit_price * (1 - amount_off.first.discounted.fdiv(100)))
    update_attribute(:discounted_price, new_price * quantity)
  end
end
