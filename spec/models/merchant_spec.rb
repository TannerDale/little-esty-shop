# frozen_string_literal: true

require 'rails_helper'
# rspec spec/models/merchant_spec.rb
RSpec.describe Merchant, type: :model do
  describe 'relationships/validations' do
    it { should have_many :items }
    it { should validate_presence_of :name }

    it 'validates default disabled status' do
      merchant = create(:merchant)
      expect(merchant.status).to eq('disabled')
    end
  end

  describe 'class methods/scopes' do
    describe 'by status' do
      before :each do
        @merch1 = create :merchant, { status: 0 }
        @merch2 = create :merchant
        @merch3 = create :merchant, { status: 0 }
        @merch4 = create :merchant
      end

      it 'has disabled' do
        expect(Merchant.by_status(1)).to eq([@merch2, @merch4])
      end

      it 'has enabled' do
        expect(Merchant.by_status(0)).to eq([@merch1, @merch3])
      end
    end
  end

  describe 'top 5 merchants by revenue' do
    let!(:merch1) { create :merchant }
    let!(:merch2) { create :merchant }
    let!(:merch3) { create :merchant }
    let!(:merch4) { create :merchant }
    let!(:merch5) { create :merchant }
    let!(:merch6) { create :merchant }

    let!(:item1) { create :item, { merchant_id: merch1.id } }

    let!(:item2) { create :item, { merchant_id: merch2.id } }
    let!(:item3) { create :item, { merchant_id: merch2.id } }

    let!(:item4) { create :item, { merchant_id: merch3.id } }
    let!(:item5) { create :item, { merchant_id: merch3.id } }

    let!(:item6) { create :item, { merchant_id: merch4.id } }
    let!(:item7) { create :item, { merchant_id: merch4.id } }

    let!(:item8) { create :item, { merchant_id: merch5.id } }
    let!(:item9) { create :item, { merchant_id: merch5.id } }

    let!(:item10) { create :item, { merchant_id: merch6.id } }

    let!(:customer) { create :customer }

    let!(:invoice1) { create :invoice, { customer_id: customer.id, created_at: DateTime.new(2021, 7, 1) } }
    let!(:invoice2) { create :invoice, { customer_id: customer.id, created_at: DateTime.new(2021, 1, 1) } }
    let!(:invoice3) { create :invoice, { customer_id: customer.id, created_at: DateTime.new(2030, 1, 1) } }

    let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 0 } }
    let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 1 } }
    let!(:transaction3) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
    let!(:transaction4) { create :transaction, { invoice_id: invoice3.id, result: 1 } }

    # 1, 50
    let!(:inv_item1) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item1.id, unit_price: 50, quantity: 1 }
    end
    # 2, 300 600
    let!(:inv_item2) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item2.id, unit_price: 100, quantity: 1 }
    end
    let!(:inv_item3) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item3.id, unit_price: 200, quantity: 1 }
    end

    # 3, 100 150
    let!(:inv_item4) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item4.id, unit_price: 100, quantity: 1 }
    end
    let!(:inv_item5) do
      create :invoice_item, { invoice_id: invoice3.id, item_id: item5.id, unit_price: 100, quantity: 1 }
    end

    # 4, 600 # 1200
    let!(:inv_item6) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item6.id, unit_price: 300, quantity: 1 }
    end
    let!(:inv_item7) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item7.id, unit_price: 300, quantity: 1 }
    end

    # 5, 500 700
    let!(:inv_item8) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item8.id, unit_price: 200, quantity: 1 }
    end
    let!(:inv_item9) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item9.id, unit_price: 300, quantity: 1 }
    end

    # 6, 150 200
    let!(:inv_item10) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item10.id, unit_price: 150, quantity: 1 }
    end
    it 'has the top 5 merchants name, total, day' do
      expected = [
        [merch4.name, 600, DateTime.new(2021, 7, 1)],
        [merch5.name, 500, DateTime.new(2021, 7, 1)],
        [merch2.name, 300, DateTime.new(2021, 1, 1)],
        [merch6.name, 150, DateTime.new(2021, 7, 1)],
        [merch3.name, 100, DateTime.new(2021, 1, 1)]
      ]
      result = Merchant.top_five_merchants
      expected.each_with_index do |merchdata, i|
        expect(result[i].name).to eq(merchdata.first)
        expect(result[i].revenue).to eq(merchdata[1])
        expect(result[i].date).to eq(merchdata.last)
      end
    end
  end

  describe 'top 5 items by revenue' do
    let!(:merchant1) { create :merchant }

    let!(:item1) { create :item, { merchant_id: merchant1.id } }
    let!(:item2) { create :item, { merchant_id: merchant1.id } }
    let!(:item3) { create :item, { merchant_id: merchant1.id } }
    let!(:item4) { create :item, { merchant_id: merchant1.id } }
    let!(:item5) { create :item, { merchant_id: merchant1.id } }
    let!(:item6) { create :item, { merchant_id: merchant1.id } }
    let!(:item7) { create :item, { merchant_id: merchant1.id } }
    let!(:item8) { create :item, { merchant_id: merchant1.id } }
    let!(:item9) { create :item, { merchant_id: merchant1.id } }
    let!(:item10) { create :item, { merchant_id: merchant1.id } }

    let!(:customer) { create :customer }

    let!(:invoice1) { create :invoice, { customer_id: customer.id, created_at: Date.today - 1 } }
    let!(:invoice2) { create :invoice, { customer_id: customer.id, created_at: Date.today } }
    let!(:invoice3) { create :invoice, { customer_id: customer.id, created_at: Date.today } }

    let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 0 } }
    let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 1 } }
    let!(:transaction3) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
    let!(:transaction4) { create :transaction, { invoice_id: invoice3.id, result: 1 } }

    let!(:inv_item1) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item1.id, unit_price: 50, quantity: 1 }
    end

    let!(:inv_item2) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item2.id, unit_price: 100, quantity: 1 }
    end
    let!(:inv_item3) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item3.id, unit_price: 200, quantity: 1 }
    end

    let!(:inv_item4) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item4.id, unit_price: 100, quantity: 1 }
    end
    let!(:inv_item5) do
      create :invoice_item, { invoice_id: invoice3.id, item_id: item5.id, unit_price: 100, quantity: 1 }
    end

    let!(:inv_item6) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item6.id, unit_price: 1000, quantity: 1 }
    end
    let!(:inv_item7) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item7.id, unit_price: 900, quantity: 1 }
    end

    let!(:inv_item8) do
      create :invoice_item, { invoice_id: invoice2.id, item_id: item8.id, unit_price: 800, quantity: 1 }
    end
    let!(:inv_item9) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item9.id, unit_price: 700, quantity: 1 }
    end

    let!(:inv_item10) do
      create :invoice_item, { invoice_id: invoice1.id, item_id: item10.id, unit_price: 600, quantity: 1 }
    end

    it 'has the top 5 items name and revenue' do
      expected = [
        [item6.name, 1000],
        [item7.name, 900],
        [item8.name, 800],
        [item9.name, 700],
        [item10.name, 600]
      ]

      result = merchant1.top_five_items

      expect(result.first.name).to eq(expected[0][0])
      expect(result.first.revenue).to eq(expected[0][1])
      expect(result.last.name).to eq(expected[-1][0])
      expect(result.last.revenue).to eq(expected[-1][1])
    end
  end

  describe 'class methods/scopes' do
    let!(:merchant) { create :merchant }
    let!(:customer) { create :customer }
    let!(:customer2) { create :customer }
    let!(:customer3) { create :customer }
    let!(:item1) { create :item, { merchant_id: merchant.id } }
    let!(:item2) { create :item, { merchant_id: merchant.id } }
    let!(:item3) { create :item, { merchant_id: merchant.id } }
    let!(:invoice1) { create :invoice, { customer_id: customer.id } }
    let!(:invoice2) { create :invoice, { customer_id: customer2.id } }
    let!(:invoice3) { create :invoice, { customer_id: customer3.id } }
    let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 1 } }
    let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
    let!(:inv_item1) { create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id } }
    let!(:inv_item2) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id } }
    let!(:inv_item3) { create :invoice_item, { item_id: item3.id, invoice_id: invoice2.id } }

    it '#merchant_fav_customers' do
      fav = [["#{customer2.first_name} #{customer2.last_name}", 1]]
      result = merchant.fav_customers

      expect(result.first.customer_name).to eq(fav.first.first)
      expect(result.first.transaction_count).to eq(fav.first.last)
    end

    it '#ordered_invoices' do
      expect(merchant.ordered_invoices).to eq([invoice1, invoice2])
    end
  end

  describe 'items ready to ship' do
    let(:status) { %w[pending packaged shipped] }
    let!(:merchant1) { create(:merchant) }
    let!(:merchant2) { create(:merchant) }
    let!(:customer) { create :customer }
    let!(:item1) { create :item, { merchant_id: merchant1.id } }
    let!(:item2) { create :item, { merchant_id: merchant1.id } }
    let!(:item3) { create :item, { merchant_id: merchant1.id } }
    let!(:item4) { create :item, { merchant_id: merchant1.id, status: 'enabled' } }
    let!(:item5) { create :item, { merchant_id: merchant2.id } }
    let!(:invoice1) { create :invoice, { customer_id: customer.id } }
    let!(:inv_item1) { create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id, status: 1 } }
    let!(:inv_item2) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id, status: 2 } }
    let!(:inv_item3) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id, status: 0 } }
    let!(:inv_item4) { create :invoice_item, { item_id: item3.id, invoice_id: invoice1.id, status: 1 } }
    let!(:inv_item5) { create :invoice_item, { item_id: item4.id, invoice_id: invoice1.id, status: 0  } }
    let!(:inv_item6) { create :invoice_item, { item_id: item5.id, invoice_id: invoice1.id, status: 1  } }

    it 'queries a merchants items not ready to ship' do
      result = merchant1.items_ready_to_ship.first
      expect(result.name).to eq(item1.name)
      expect(result.invoices_id).to eq(invoice1.id)
    end

    it 'has next_id' do
      expected = Merchant.maximum(:id).next
      expect(Merchant.next_id).to eq(expected)
    end
  end
end
