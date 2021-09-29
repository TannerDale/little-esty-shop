# frozen_string_literal: true

require 'rails_helper'
# rspec spec/models/invoice_spec.rb
RSpec.describe Invoice, type: :model do
  describe 'relationships' do
    it { should belong_to(:customer) }
    it { should have_many(:invoice_items) }
    it { should have_many(:items).through(:invoice_items) }
    it { should have_many(:merchants).through(:items) }
    it { should have_many(:discounts).through(:merchants) }
    it { should have_many(:transactions) }
  end

  describe 'class methods/scopes' do
    let(:invoice) { create :invoice }
    let(:status) { ['in progress', 'completed', 'cancelled'] }
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
    let!(:inv_item1) { create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id } }
    let!(:inv_item2) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id } }
    let!(:inv_item3) { create :invoice_item, { item_id: item3.id, invoice_id: invoice2.id } }

    context 'for merchants' do
      let!(:merchant) { create :merchant }
      let!(:customer) { create :customer }
      let!(:item1) { create :item, { merchant_id: merchant.id } }
      let!(:item2) { create :item, { merchant_id: merchant.id } }
      let!(:item3) { create :item, { merchant_id: merchant.id } }
      let!(:invoice1) { create :invoice, { customer_id: customer.id, status: 0 } }
      let!(:invoice2) { create :invoice, { customer_id: customer.id, status: 0 } }
      let!(:invoice3) { create :invoice, { customer_id: customer.id, status: 1 } }
      let!(:invoice4) { create :invoice, { customer_id: customer.id, status: 2 } }
      let!(:inv_item1) { create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id, status: 0 } }
      let!(:inv_item2) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id, status: 1 } }
      let!(:inv_item3) { create :invoice_item, { item_id: item3.id, invoice_id: invoice2.id, status: 2 } }

      it '#incomplete_invoices' do
        expect(Invoice.incomplete_invoices).to eq([invoice1])
      end

      it 'has a transaction count' do
        result = Invoice.joins(:transactions).transactions_count.group(:id)
        result = result.sum(&:transaction_count)

        expect(result).to eq(2)
      end

      it 'has total revenues' do
        expected = [inv_item1, inv_item2, inv_item3].sum do |inv|
          inv.unit_price * inv.quantity
        end
        result = Invoice.joins(:invoice_items).total_revenues.group(:id)
        result = result.sum(&:revenue)

        expect(result).to eq(expected)
      end
    end
  end

  describe 'instance methods' do
    describe 'total revenue' do
      let!(:customer) { create :customer }
      let!(:merchant) { create :merchant }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:item1) { create :item, { merchant_id: merchant.id } }
      let!(:item2) { create :item, { merchant_id: merchant.id } }
      let!(:item3) { create :item, { merchant_id: merchant.id } }
      let!(:inv_item1) do
        create :invoice_item, { invoice_id: invoice.id, item_id: item1.id, unit_price: 100, quantity: 1 }
      end
      let!(:inv_item2) do
        create :invoice_item, { invoice_id: invoice.id, item_id: item2.id, unit_price: 150, quantity: 2 }
      end
      let!(:inv_item3) do
        create :invoice_item, { invoice_id: invoice.id, item_id: item3.id, unit_price: 300, quantity: 1 }
      end

      it '#total_revenues' do
        expect(invoice.total_revenue).to eq(700)
      end
    end
  end

  describe 'discounts' do
    describe 'example 1' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:merchant) { create :merchant }

      let!(:itemA) { create :item, { merchant_id: merchant.id } }
      let!(:itemB) { create :item, { merchant_id: merchant.id } }

       # 5
      let!(:inv_itemA) { create :invoice_item, { item_id: itemA.id, invoice_id: invoice.id, quantity: 5, unit_price: 100 } }
      let!(:inv_itemB) { create :invoice_item, { item_id: itemB.id, invoice_id: invoice.id, quantity: 5, unit_price: 100 } }
      # 5

      let!(:discount) { create :discount, { percentage: 20, quantity: 10, merchant_id: merchant.id } }

      it 'has no discount' do
        result = invoice.discounts_and_discounted_total
        discounted = 1000

        expect(result.keys - [:discounted_total]).to be_empty

        expect(result[:discounted_total]).to eq(discounted)
      end
    end

    describe 'example 2' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:merchant) { create :merchant }

      let!(:itemA) { create :item, { merchant_id: merchant.id } }
      let!(:itemB) { create :item, { merchant_id: merchant.id } }

      # 10
      let!(:inv_itemA) { create :invoice_item, { item_id: itemA.id, invoice_id: invoice.id, quantity: 10, unit_price: 100 } }
      let!(:inv_itemB) { create :invoice_item, { item_id: itemB.id, invoice_id: invoice.id, quantity: 5, unit_price: 100 } }
      # 5

      let!(:discount) { create :discount, { percentage: 20, quantity: 10, merchant_id: merchant.id } }

      it 'has one discount to item A' do
        result = invoice.discounts_and_discounted_total
        discounted = 1300

        expect(result.keys - [:discounted_total]).to eq([inv_itemA.id])

        expect(result[:discounted_total]).to eq(discounted)
        expect(result[inv_itemA.id]).to have_value(discount.id)
      end
    end

    describe 'example 3' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:merchant) { create :merchant }

      let!(:itemA) { create :item, { merchant_id: merchant.id } }
      let!(:itemB) { create :item, { merchant_id: merchant.id } }

      # 12
      let!(:inv_itemA) { create :invoice_item, { item_id: itemA.id, invoice_id: invoice.id, quantity: 12, unit_price: 100 } }
      let!(:inv_itemB) { create :invoice_item, { item_id: itemB.id, invoice_id: invoice.id, quantity: 15, unit_price: 100 } }
      # 15

      let!(:discountA) { create :discount, { percentage: 20, quantity: 10, merchant_id: merchant.id } }
      let!(:discountB) { create :discount, { percentage: 30, quantity: 15, merchant_id: merchant.id } }

      describe 'full results' do
        it 'discountA to inv_itemA, discountB to inv_itemB' do
          result = invoice.discounts_and_discounted_total
          discounted = 2010

          expect(result.keys - [:discounted_total]).to eq([inv_itemB.id, inv_itemA.id])
          expect(result[:discounted_total]).to eq(discounted)
          expect(result[inv_itemA.id]).to have_value(discountA.id)
          expect(result[inv_itemB.id]).to have_value(discountB.id)
        end
      end

      describe 'helper methods' do
        it 'has discounts and totals' do
          result = invoice.inv_item_discounts

          expect(result.length).to eq(3)
        end

        it 'has discount and amount off per invoice item' do
          result = invoice.discount_and_total

          expect(result[inv_itemA.id][:id]).to eq(discountA.id)
          expect(result[inv_itemB.id][:id]).to eq(discountB.id)

          expect(result[inv_itemA.id][:amount_off]).to eq(240)
          expect(result[inv_itemB.id][:amount_off]).to eq(450)
        end

        it 'has discount info' do
          result = invoice.discounts_and_discounted_total
          discounted = 2010

          expect(result.keys - [:discounted_total]).to eq([inv_itemB.id, inv_itemA.id])
          expect(result[:discounted_total]).to eq(discounted)
          expect(result[inv_itemA.id]).to have_value(discountA.id)
          expect(result[inv_itemB.id]).to have_value(discountB.id)
        end
      end
    end

    describe 'example 4' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:merchant) { create :merchant }

      let!(:itemA) { create :item, { merchant_id: merchant.id } }
      let!(:itemB) { create :item, { merchant_id: merchant.id } }

      # 12
      let!(:inv_itemA) { create :invoice_item, { item_id: itemA.id, invoice_id: invoice.id, quantity: 12, unit_price: 100 } }
      let!(:inv_itemB) { create :invoice_item, { item_id: itemB.id, invoice_id: invoice.id, quantity: 15, unit_price: 100 } }
      # 15

      let!(:discountA) { create :discount, { percentage: 20, quantity: 12, merchant_id: merchant.id } }
      let!(:discountB) { create :discount, { percentage: 15, quantity: 15, merchant_id: merchant.id } }

      it 'discountA to inv_itemA and inv_itemB' do
        result = invoice.discounts_and_discounted_total
        discounted = 2160

        expect(result.keys - [:discounted_total])
          .to eq([inv_itemB.id, inv_itemA.id])
          .or eq([inv_itemA.id, inv_itemB.id])

        expect(result[:discounted_total]).to eq(discounted)
        expect(result[inv_itemA.id]).to have_value(discountA.id)
        expect(result[inv_itemB.id]).to have_value(discountA.id)
      end
    end

    describe 'example 5' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id } }
      let!(:merchantA) { create :merchant }
      let!(:merchantB) { create :merchant }

      let!(:itemA1) { create :item, { merchant_id: merchantA.id } }
      let!(:itemA2) { create :item, { merchant_id: merchantA.id } }
      let!(:itemB) { create :item, { merchant_id: merchantB.id } }

      # 12
      let!(:inv_itemA1) { create :invoice_item, { item_id: itemA1.id, invoice_id: invoice.id, quantity: 12, unit_price: 100 } }
      # 15
      let!(:inv_itemA2) { create :invoice_item, { item_id: itemA2.id, invoice_id: invoice.id, quantity: 15, unit_price: 100 } }
      # 15
      let!(:inv_itemB) { create :invoice_item, { item_id: itemB.id, invoice_id: invoice.id, quantity: 15, unit_price: 100 } }

      let!(:discountA1) { create :discount, { percentage: 20, quantity: 12, merchant_id: merchantA.id } }
      let!(:discountA2) { create :discount, { percentage: 30, quantity: 15, merchant_id: merchantA.id } }

      it 'discountA1 to inv_itemA1, discountA2 to inv_itemA2' do
        result = invoice.discounts_and_discounted_total
        discounted = 3510

        expect(result.keys - [:discounted_total])
          .to eq([inv_itemA1.id, inv_itemA2.id])
          .or eq([inv_itemA2.id, inv_itemA1.id])

        expect(result[:discounted_total]).to eq(discounted)
        expect(result[inv_itemA1.id]).to have_value(discountA1.id)
        expect(result[inv_itemA2.id]).to have_value(discountA2.id)
      end
    end

    describe 'adding discounted price to invoice items' do
      let!(:customer) { create :customer }
      let!(:invoice) { create :invoice, { customer_id: customer.id, status: 1 } }
      let!(:merchantA) { create :merchant }

      let!(:itemA1) { create :item, { merchant_id: merchantA.id } }
      let!(:itemA2) { create :item, { merchant_id: merchantA.id } }

      # 12
      let!(:inv_itemA1) { create :invoice_item, { item_id: itemA1.id, invoice_id: invoice.id, quantity: 12, unit_price: 100 } }
      # 15
      let!(:inv_itemA2) { create :invoice_item, { item_id: itemA2.id, invoice_id: invoice.id, quantity: 15, unit_price: 100 } }
      # 15

      let!(:discountA1) { create :discount, { percentage: 20, quantity: 12, merchant_id: merchantA.id } }

      it 'can add a discounted price to its invoice items' do
        invoice.lock_discounted_prices

        inv_itemA1.reload
        inv_itemA2.reload

        expect(inv_itemA1.discounted_price).to eq(960)
        expect(inv_itemA2.discounted_price).to eq(1200)
      end
    end
  end
end
