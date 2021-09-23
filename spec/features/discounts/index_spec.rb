require 'rails_helper'

RSpec.describe 'discounts index' do
  describe 'index page' do
    let(:merchant) { create :merchant }
    let!(:discount1) { create :discount, { merchant_id: merchant.id } }
    let!(:discount2) { create :discount, { merchant_id: merchant.id } }
    let!(:discount3) { create :discount, { merchant_id: merchant.id } }

    before :each do
      visit merchant_discounts_path(merchant)
    end

    it 'has all of the discounts and their info' do
      [discount1, discount2, discount3].each do |discount|
        expect(page).to have_content(discount.quantity)
        expect(page).to have_content(discount.percentage.fdiv(100))
      end
    end
  end
end
