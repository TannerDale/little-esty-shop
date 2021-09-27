# frozen_string_literal: true

require 'rails_helper'
# rspec spec/features/invoices/show_spec.rb
RSpec.describe 'Merchant Invoice Show Page' do
  describe 'Merchant Invoice Show Page' do
    before :each do
      @merchant = create :merchant
      @merchant2 = create :merchant

      @customer = create :customer

      @invoice1 = create :invoice, { customer_id: @customer.id, created_at: DateTime.new(2021, 9, 18) }
      @invoice2 = create :invoice, { customer_id: @customer.id, created_at: DateTime.new(2021, 9, 17) }

      @item1 = create :item, { merchant_id: @merchant.id, status: 'enabled' }
      @item2 = create :item, { merchant_id: @merchant.id }
      @item3 = create :item, { merchant_id: @merchant2.id }

      @invoice_item1 = create :invoice_item,
                              { invoice_id: @invoice1.id, item_id: @item1.id, unit_price: 50, quantity: 1, status: 0 }
      @invoice_item2 = create :invoice_item,
                              { invoice_id: @invoice1.id, item_id: @item2.id, unit_price: 100, quantity: 1, status: 1 }
      @invoice_item3 = create :invoice_item,
                              { invoice_id: @invoice2.id, item_id: @item3.id, unit_price: 200, quantity: 1, status: 2 }

      visit merchant_invoice_path(@merchant, @invoice1)
    end

    it 'has invoice attributes' do
      expect(page).to have_content(@invoice1.id)
      expect(page).to have_content(@invoice1.status)
      expect(page).to have_content('Saturday, September 18, 2021')
      expect(page).to have_content(@invoice1.customer.full_name)
      expect(page).to have_content(@invoice1.total_revenue)
      expect(page).to have_content('$150.00')
    end

    context 'Merchant Invoice Show Page - Invoice Item Information' do
      it "lists all invoice items' names, quantity, price, status" do
        expect(page).to have_content(@invoice_item1.item.name)
        expect(page).to have_content(@invoice_item1.quantity)
        expect(page).to have_content(@invoice_item1.unit_price)
        expect(page).to have_content(@invoice_item1.status)
        expect(page).to have_no_content(@invoice_item3.item.name)
      end

      it 'updates inv item status' do
        within "#inv_item-#{@invoice_item1.id}" do
          expect(find_field('invoice_item_status').value).to eq('pending')
          select 'packaged'
          click_on 'Update'
        end
        expect(current_path).to eq(merchant_invoice_path(@merchant, @invoice1))

        within "#inv_item-#{@invoice_item1.id}" do
          expect(find_field('invoice_item_status').value).to eq('packaged')
          expect(page).to have_content('packaged')
        end
      end
    end
  end

  describe 'discounts' do
    describe 'with discounts' do
      describe 'example 5 pt 2' do
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
          visit merchant_invoice_path(merchantA, invoice)
        end

        it 'has the discounted total' do
          expect(page).to have_content('Discounted Total: $35.10')
          expect(page).to have_content('Total: $42.00')
        end

        it 'has a link to the discount applied to the item' do
          within "#inv_item-#{inv_itemB.id}" do
            expect(page).to have_content('No Discount Applied')
          end

          within "#inv_item-#{inv_itemA1.id}" do
            expect(page).to have_link(discountA1.id)
          end

          within "#inv_item-#{inv_itemA2.id}" do
            expect(page).to have_link(discountA2.id)

            click_on discountA2.id
          end

          expect(current_path).to eq(merchant_discount_path(merchantA, discountA2))
        end
      end
    end
  end
end
