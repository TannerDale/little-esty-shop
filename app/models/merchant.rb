# frozen_string_literal: true

class Merchant < ApplicationRecord
  self.primary_key = :id
  validates_presence_of :name

  has_many :discounts
  has_many :items, dependent: :destroy
  has_many :invoice_items, through: :items
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices
  has_many :customers, through: :invoices

  enum status: %w[enabled disabled]

  def self.next_id
    maximum(:id).next || 1
  end

  def self.top_five_merchants
    joins(:transactions)
      .merge(Transaction.success)
      .select(:name, 'MAX(invoices.created_at) AS date')
      .merge(Invoice.total_revenues)
      .group(:id)
      .order(revenue: :desc)
      .limit(5)
  end

  def items_ready_to_ship
    invoices
      .merge(InvoiceItem.not_shipped)
      .select('items.name AS name, invoices.id AS invoices_id, invoices.created_at AS invoices_created_at')
      .order(:invoices_created_at)
  end

  def ordered_invoices
    invoices.order(:created_at).distinct
  end

  def fav_customers
    transactions
      .success
      .joins(invoice: :customer)
      .group('customers.id')
      .merge(Customer.full_names)
      .merge(Invoice.transactions_count)
      .order(transaction_count: :desc)
      .limit(5)
  end

  def top_five_items
    items
      .joins(:transactions)
      .merge(Transaction.success)
      .select('items.*, MAX(invoices.created_at) AS date')
      .merge(Invoice.total_revenues)
      .group(:id)
      .order(revenue: :desc)
      .limit(5)
  end
end
