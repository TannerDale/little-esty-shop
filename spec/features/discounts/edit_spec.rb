require 'rails_helper'

RSpec.describe 'discount edit' do
  describe 'discount edit page' do
    let!(:merchant) { create :merchant }
    let!(:discount) { create :discount, { merchant_id: merchant.id } }

    before :each do
      visit edit_merchant_discount_path(merchant, discount)
    end

    it 'can update a discount' do
      expect(page.first(:css, '#discount_percentage')[:value]).to eq(discount.percentage.to_s)
      expect(page.first(:css, '#discount_quantity')[:value]).to eq(discount.quantity.to_s)


      fill_in :discount_percentage, with: 99
      fill_in :discount_quantity, with: 97
      click_on 'Update Discount'

      expect(current_path).to eq(merchant_discount_path(merchant, discount))
      expect(page).to have_content(99)
      expect(page).to have_content(97)
    end

    it 'rejects invalid update values' do
      fill_in :discount_quantity, with: ''
      click_on 'Update Discount'

      expect(current_path).to eq(edit_merchant_discount_path(merchant, discount))

      fill_in :discount_percentage, with: ''
      click_on 'Update Discount'

      expect(current_path).to eq(edit_merchant_discount_path(merchant, discount))
    end
  end
end
