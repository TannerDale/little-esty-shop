require 'rails_helper'

RSpec.describe 'Merchant discount show' do
  describe 'Merchant discount show page' do
    let!(:merchant) { create :merchant }
    let!(:discount) { create :discount, { merchant_id: merchant.id } }

    before :each do
      visit merchant_discount_path(merchant, discount)
    end

    it 'has the quantity threshhold and percentage off' do
      expect(page).to have_content("Quantity Threshhold: #{discount.quantity}")
      expect(page).to have_content("Percentage Off: #{discount.percentage}%")
    end

    it 'has a link to edit the discount' do
      click_on 'Edit Discount'

      expect(current_path).to eq(edit_merchant_discount_path(merchant, discount))
    end
  end
end
