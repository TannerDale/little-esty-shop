# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Invoice Show Page' do
  before do
    @customer = create(:customer)

    @item_1 = create(:item)
    @item_2 = create(:item)
    @item_3 = create(:item)

    @invoice = create(:invoice, customer_id: @customer.id)

    @invoice_item_1 = create(:invoice_item, item_id: @item_1.id, invoice_id: @invoice.id, unit_price: 1)
    @invoice_item_2 = create(:invoice_item, item_id: @item_2.id, invoice_id: @invoice.id, unit_price: 1)
    @invoice_item_3 = create(:invoice_item, item_id: @item_3.id, invoice_id: @invoice.id, unit_price: 1)

    visit admin_invoice_path(@invoice.id)
  end

  describe 'i see information related to invoice' do
    it 'when i visit an admin invoice show page' do
      expect(current_path).to eq(admin_invoice_path(@invoice.id))
    end

    it 'has invoice id, status, created, cust first and last' do
      expect(page).to have_content(@invoice.id.to_s)
      expect(page).to have_content(@invoice.status.to_s)
      expect(page).to have_content(@invoice.created_at.strftime('%A, %B %e, %Y'))
      expect(page).to have_content(@invoice.customer.first_name)
      expect(page).to have_content(@invoice.customer.last_name)
    end

    it 'has item name, quant, price sold, and inv. item status' do
      expect(page).to have_content(@item_1.name)
      expect(page).to have_content(@item_2.name)
      expect(page).to have_content(@item_3.name)
      expect(page).to have_content(@invoice_item_1.quantity)
      expect(page).to have_content(@invoice_item_2.quantity)
      expect(page).to have_content(@invoice_item_3.quantity)
      expect(page).to have_content(@invoice_item_1.unit_price)
      expect(page).to have_content(@invoice_item_2.unit_price)
      expect(page).to have_content(@invoice_item_3.unit_price)
      expect(page).to have_content(@invoice_item_1.status)
      expect(page).to have_content(@invoice_item_2.status)
      expect(page).to have_content(@invoice_item_3.status)
    end
  end

  describe 'total revenue / updating status' do
    let!(:customer) { create :customer }
    let!(:merchant) { create :merchant }
    let!(:invoice) { create :invoice, { customer_id: customer.id } }
    let!(:item) { create :item, { merchant_id: merchant.id } }
    let!(:invoice_item) do
      create :invoice_item, { invoice_id: invoice.id, item_id: item.id, unit_price: 13_000, quantity: 1 }
    end

    it 'shows the total revenue' do
      visit admin_invoice_path(invoice)

      within '#invoice-attr' do
        expect(page).to have_content('$130.00')
      end
    end

    it 'has button to update the status' do
      select 'cancelled', from: 'invoice_status'
      click_button 'Update Status'

      expect(find_field('invoice_status').value).to eq('cancelled')

      expect(current_path).to eq(admin_invoice_path(@invoice))
    end
  end

  describe 'discounted info' do
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

    before :each do
      visit admin_invoice_path(invoice)
    end

    it 'has the total and discount_revenue' do
      expect(page).to have_content('Discounted Revenue: $35.10')
      expect(page).to have_content('Revenue: $42.00')
    end
  end
end
