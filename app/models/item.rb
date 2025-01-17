# frozen_string_literal: true

class Item < ApplicationRecord
  validates_presence_of :name

  belongs_to :merchant
  has_many :discounts, through: :merchant
  has_many :invoice_items, dependent: :destroy
  has_many :invoices, through: :invoice_items
  has_many :transactions, through: :invoices

  scope :by_status, ->(status) {
    where(status: status)
  }

  def self.next_id
    maximum(:id).next
  end
end
