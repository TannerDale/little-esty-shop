# frozen_string_literal: true

require 'rails_helper'
# rspec spec/features/items/index_spec.rb
RSpec.describe 'Merchant Items Index Page' do
  describe 'Merchant Items Index Page' do
    before :each do
      @merchant = create :merchant
      @merchant2 = create :merchant

      @item1 = create :item, { merchant_id: @merchant.id, status: 'enabled' }
      @item2 = create :item, { merchant_id: @merchant.id }
      @item3 = create :item, { merchant_id: @merchant2.id }

      visit merchant_items_path(@merchant)
    end

    it 'lists all item names' do
      expect(page).to have_content(@item1.name)
      expect(page).to have_content(@item2.name)
      expect(page).to have_no_content(@item3.name)
    end

    it 'links items to show page' do
      expect(page).to have_link(@item1.name)

      click_link @item1.name

      expect(current_path).to eq(merchant_item_path(@merchant, @item1))
    end

    it 'has a disable and enable button' do
      expect(page).to have_button("Enable #{@item2.name}")

      click_button "Enable #{@item2.name}"

      expect(current_path).to eq(merchant_items_path(@merchant))
      expect(page).to have_no_button("Enable #{@item2.name}")
      expect(page).to have_button("Disable #{@item2.name}")

      click_button "Disable #{@item2.name}"

      expect(current_path).to eq(merchant_items_path(@merchant))
      expect(page).to have_no_button("Disable #{@item2.name}")
    end

    it 'has a disable and enable section' do
      within '#enabled' do
        expect(page).to have_button("Disable #{@item1.name}")
        expect(page).to have_no_button("Enable #{@item1.name}")
      end

      within '#disabled' do
        expect(page).to have_button("Enable #{@item2.name}")
        expect(page).to have_no_button("Disable #{@item2.name}")
      end
    end

    it 'has a link to create new item' do
      expect(page).to have_link('Create Item')

      click_link 'Create Item'

      expect(current_path).to eq(new_merchant_item_path(@merchant))
    end

    describe 'most popular items' do
      let!(:item4) { create :item, { merchant_id: @merchant.id } }
      let!(:item5) { create :item, { merchant_id: @merchant.id } }
      let!(:item6) { create :item, { merchant_id: @merchant.id } }
      let!(:item7) { create :item, { merchant_id: @merchant.id } }
      let!(:item8) { create :item, { merchant_id: @merchant.id } }
      let!(:item9) { create :item, { merchant_id: @merchant.id } }
      let!(:item10) { create :item, { merchant_id: @merchant.id } }

      let!(:customer) { create :customer }

      let!(:invoice1) { create :invoice, { customer_id: customer.id, created_at: Date.today - 1 } }
      let!(:invoice2) { create :invoice, { customer_id: customer.id, created_at: Date.today } }
      let!(:invoice3) { create :invoice, { customer_id: customer.id, created_at: Date.today } }

      let!(:transaction1) { create :transaction, { invoice_id: invoice1.id, result: 0 } }
      let!(:transaction2) { create :transaction, { invoice_id: invoice2.id, result: 1 } }
      let!(:transaction3) { create :transaction, { invoice_id: invoice2.id, result: 0 } }
      let!(:transaction4) { create :transaction, { invoice_id: invoice3.id, result: 1 } }

      let!(:inv_item1) do
        create :invoice_item, { invoice_id: invoice1.id, item_id: @item1.id, unit_price: 50, quantity: 1 }
      end
      let!(:inv_item2) do
        create :invoice_item, { invoice_id: invoice2.id, item_id: @item2.id, unit_price: 100, quantity: 1 }
      end
      let!(:inv_item3) do
        create :invoice_item, { invoice_id: invoice2.id, item_id: @item3.id, unit_price: 200, quantity: 1 }
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

      it 'has the top 5 items name, revenue, and best day' do
        visit merchant_items_path(@merchant)

        expect(page).to have_content('Top 5 Most Popular Items')

        within '#most_popular' do
          expect(page).to have_content(item6.name)
          expect(page).to have_content('$10.00')
          expect(page).to have_content(Date.today.strftime('%A, %B %e, %Y'))
          expect(item6.name).to appear_before(item7.name)
        end
      end

      it 'links to each popular items show page' do
        visit merchant_items_path(@merchant)
        within '#most_popular' do
          expect(page).to have_link(item6.name)
          expect(page).to have_link(item7.name)
          expect(page).to have_link(item8.name)
          expect(page).to have_link(item9.name)
          expect(page).to have_link(item10.name)

          within "#item-#{item6.id}" do
            click_on item6.name
          end
        end
        expect(current_path).to eq(merchant_item_path(@merchant, item6))
      end
    end
  end
end
