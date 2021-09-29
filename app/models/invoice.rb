# frozen_string_literal: true

class Invoice < ApplicationRecord
  after_update :lock_discounted_prices

  belongs_to :customer
  has_many :invoice_items, dependent: :destroy
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items
  has_many :discounts, through: :merchants
  has_many :transactions, dependent: :destroy

  enum status: ['in progress', 'completed', 'cancelled']

  def self.incomplete_invoices
    joins(:invoice_items)
      .merge(InvoiceItem.not_shipped)
      .order(:created_at)
      .distinct
  end

  scope :transactions_count, -> {
    select('COUNT(transactions.id) AS transaction_count')
  }

  scope :total_revenues, -> {
    select('SUM(invoice_items.unit_price * invoice_items.quantity) AS revenue')
  }

  def total_revenue
    invoice_items.revenue
  end

  def inv_item_discounts
    invoice_items.applicable_discounts
  end

  def discounts_and_discounted_total
    discounted_info
  end

  def discount_and_total
    inv_item_discounts.group_by(&:id).map do |inv_item_id, discount|
      max_d = discount.max_by(&:percentage)
      amount_off = max_d.revenue * max_d.percentage.fdiv(100)

      discount_info = {
        id: max_d.discount,
        amount_off: amount_off
      }

      [inv_item_id, discount_info]
    end.to_h
  end

  def discounted_info
    result = discount_and_total
    price_off = result.sum do |_inv, dis|
      dis[:amount_off]
    end
    result.merge({ discounted_total: total_revenue - price_off })
  end

  def lock_discounted_prices
    return unless completed?
    Invoice.transaction do
      invoice_items.each do |inv_item|
        inv_item.lock_discounted_price
      end
    end
  end
end
