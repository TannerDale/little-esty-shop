require 'rails_helper'

FakeHoliday = Struct.new(:name, :date)

RSpec.describe 'discounts index' do
  describe 'index page' do
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

      visit merchant_discounts_path(merchant)
    end

    it 'has all of the discounts and their info' do
      [discount1, discount2, discount3].each do |discount|
        expect(page).to have_content(discount.quantity)
        expect(page).to have_content(discount.percentage)
      end
    end

    it 'has links to discount show pages' do
      within "#discount-#{discount1.id}" do
        click_on 'Discount Page'
      end

      expect(current_path).to eq(merchant_discount_path(merchant, discount1))
    end

    it 'has the next 3 discounts' do
      within '#upcoming-holidays' do
        holidays.each do |holiday|
          expect(page).to have_content(holiday.name)
          expect(page).to have_content(holiday.date.strftime('%b %d, %Y'))
        end
      end
    end

    it 'has a link to make a new discount' do
      click_link 'New Discount'

      expect(current_path).to eq(new_merchant_discount_path(merchant))
    end

    it 'has a link to destroy a discount' do
      within "#discount-#{discount1.id}"  do
        click_on 'Delete Discount'
      end

      expect(Discount.count).to eq(2)
    end
  end
end
