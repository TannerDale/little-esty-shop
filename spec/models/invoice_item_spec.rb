require 'rails_helper'
# rspec spec/models/invoice_item_spec.rb
RSpec.describe InvoiceItem, type: :model do

  describe 'validations' do
    it { belong_to :item }
    it { belong_to :invoice }
    it { should validate_presence_of :status }
  end

  describe 'enum' do
    let(:status){['pending','packaged','shipped']}
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
    let!(:invoice1) { create :invoice, { customer_id: customer.id} }
    let!(:invoice2) { create :invoice, { customer_id: customer2.id } }
    let!(:invoice3) { create :invoice, { customer_id: customer2.id} }
    let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 1} }
    let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
    let!(:inv_item1) { create :invoice_item, { item_id: item1.id, invoice_id: invoice1.id, status: 0, quantity: 1, unit_price: 100 } }
    let!(:inv_item2) { create :invoice_item, { item_id: item2.id, invoice_id: invoice1.id, status: 1, quantity: 2, unit_price: 100 } }
    let!(:inv_item3) { create :invoice_item, { item_id: item3.id, invoice_id: invoice2.id, status: 2, quantity: 1, unit_price: 150 } }

    it 'has not shipped items' do
      expect(InvoiceItem.not_shipped).to eq([inv_item1, inv_item2])
    end

    it 'has a total revenue' do
      expect(InvoiceItem.revenue).to eq(450)
    end
  end
end
