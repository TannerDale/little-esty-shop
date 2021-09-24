# frozen_string_literal: true

require 'rails_helper'
# rspec spec/models/invoice_item_spec.rb
RSpec.describe InvoiceItem, type: :model do
  describe 'validations' do
    it { belong_to :item }
    it { belong_to :invoice }
    it { have_one(:merchant).through :item }
    it { have_many(:discounts).through :merchant }
    it { should validate_presence_of :status }
  end

  describe 'enum' do
    let(:status) { %w[pending packaged shipped] }
    it 'has the right index' do
      status.each_with_index do |item, index|
        expect(InvoiceItem.statuses[item]).to eq(index)
      end
    end
  end

  describe 'scopes and class methods' do
    let(:invoice) { create :invoice }
    let!(:merchant) { create :merchant }
    let!(:customer) { create :customer }
    let!(:customer2) { create :customer }
    let!(:item1) { create :item, { merchant_id: merchant.id } }
    let!(:item2) { create :item, { merchant_id: merchant.id } }
    let!(:item3) { create :item, { merchant_id: merchant.id } }
    let!(:invoice1) { create :invoice, { customer_id: customer.id } }
    let!(:invoice2) { create :invoice, { customer_id: customer2.id } }
    let!(:invoice3) { create :invoice, { customer_id: customer2.id } }
    let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 1 } }
    let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
    let!(:inv_item1) do
      create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id, status: 0, quantity: 1, unit_price: 100 }
    end
    let!(:inv_item2) do
      create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id, status: 1, quantity: 2, unit_price: 100 }
    end
    let!(:inv_item3) do
      create :invoice_item, { item_id: item3.id, invoice_id: invoice2.id, status: 2, quantity: 1, unit_price: 150 }
    end

    it 'has not shipped items' do
      expect(InvoiceItem.not_shipped).to eq([inv_item1, inv_item2])
    end

    it 'has a total revenue' do
      expect(InvoiceItem.revenue).to eq(450)
    end
  end

  describe 'i hate myself' do
    let!(:customer) { create :customer }
    let!(:invoice) { create :invoice, { customer_id: customer.id } }
    let!(:merchant) { create :merchant }
    let!(:merchant2) { create :merchant }

    let!(:item1) { create :item, { merchant_id: merchant.id } }
    let!(:item2) { create :item, { merchant_id: merchant.id } }
    let!(:item3) { create :item, { merchant_id: merchant2.id } }
    let!(:item4) { create :item, { merchant_id: merchant2.id } }

    let!(:transaction1) { create :transaction, { invoice_id: invoice.id, result: 0 } }
    let!(:transaction2) { create :transaction, { invoice_id: invoice.id, result: 0 } }

    let!(:inv_item1) do
      create :invoice_item, { item_id: item1.id, invoice_id: invoice.id, status: 0, quantity: 6, unit_price: 100 }
    end
    let!(:inv_item2) do
      create :invoice_item, { item_id: item2.id, invoice_id: invoice.id, status: 1, quantity: 6, unit_price: 100 }
    end
    let!(:inv_item3) do
      create :invoice_item, { item_id: item3.id, invoice_id: invoice.id, status: 1, quantity: 5, unit_price: 150 }
    end
    let!(:inv_item4) do
      create :invoice_item, { item_id: item3.id, invoice_id: invoice.id, status: 0, quantity: 7, unit_price: 150 }
    end

    let!(:discount1) { create :discount, { merchant_id: merchant.id, quantity: 10 } }
    let!(:discount2) { create :discount, { merchant_id: merchant2.id, quantity: 10 } }

    it 'has the discounts' do
      result = invoice.invoice_items.discounted
      result = result.map(&:discount_item).uniq.map { |i| Merchant.find(Item.find(i).merchant_id) }.uniq

      expect(result).to eq([merchant, merchant2]).or eq([merchant2, merchant])
    end
  end
end
