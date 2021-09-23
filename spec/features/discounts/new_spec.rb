require 'rails_helper'

RSpec.describe 'discounts new' do
  describe 'discounts new page' do
    let(:merchant) { create :merchant }
    let!(:discount1) { create :discount, { merchant_id: merchant.id } }
    let!(:discount2) { create :discount, { merchant_id: merchant.id } }
    let!(:discount3) { create :discount, { merchant_id: merchant.id } }
    let!(:hol1) { FakeHoliday.new('Happy', Date.today) }
    let!(:hol2) { FakeHoliday.new('Birthday', Date.today + 1) }
    let!(:hol3) { FakeHoliday.new('You', Date.today + 2) }
    let(:holidays) { [hol1, hol2, hol3] }

    before :each do
      allow(HolidayService).to receive(:next_three).and_return(holidays)

      visit new_merchant_discount_path(merchant)
    end

    it 'can make a new discount' do
      within '#form' do
        fill_in :discount_quantity, with: 10
        fill_in :discount_percentage, with: 25

        click_on 'Create Discount'
      end

      expect(current_path).to eq(merchant_discounts_path(merchant))
      expect(page).to have_content('25%')
    end
  end
end
