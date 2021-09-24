# frozen_string_literal: true

class Customer < ApplicationRecord
  self.primary_key = :id

  has_many :invoices, dependent: :destroy
  has_many :transactions, through: :invoices
  has_many :invoice_items, through: :invoices
  has_many :items, through: :invoice_items
  has_many :merchants, through: :items

  def self.top_5_customers
    joins(:transactions)
      .merge(Transaction.success)
      .group(:id)
      .limit(5)
      .merge(Invoice.transactions_count)
      .order(count: :desc)
      .full_names
  end

  scope :full_names, -> {
    select("customers.first_name || ' ' || customers.last_name AS customer_name")
  }

  def full_name
    "#{first_name} #{last_name}"
  end
end
