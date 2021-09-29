# frozen_string_literal: true

require 'rails_helper'
# rspec spec/models/item_spec.rb
RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
    it { should have_many(:discounts).through(:merchant) }
    it { should have_many(:invoice_items) }
    it { should have_many(:invoices).through(:invoice_items) }
    it { should have_many(:transactions).through(:invoices) }

    it 'validates default disabled status' do
      item = create(:item)
      expect(item.status).to eq('disabled')
    end
  end

  describe 'by status' do
    before :each do
      @merchant_a = create :merchant, { id: 20 }
      @item_a = create :item, { merchant_id: @merchant_a.id, status: 'enabled' }
      @item_b = create :item, { merchant_id: @merchant_a.id }
      @item_c = create :item, { merchant_id: @merchant_a.id }
      @item_d = create :item, { merchant_id: @merchant_a.id }
    end

    it 'returns items by status disabled' do
      result = @merchant_a.items.by_status('disabled')

      expected = [@item_b, @item_c, @item_d]
      result.all? do |item|
        expect(expected.include?(item)).to be true
      end
      expect(result.length).to eq(3)
    end

    it 'returns items by status enabled' do
      expect(@merchant_a.items.by_status('enabled')).to eq([@item_a])
    end

    it 'has the next id' do
      expect(Item.next_id).to eq(Item.maximum(:id).next)
    end
  end
end
