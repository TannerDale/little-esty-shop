require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations/relationships' do
    it { should belong_to :merchant }
    it { should have_many(:items).through :merchant }
    it { should have_many(:invoice_items).through :items }
    it { should have_many(:invoices).through :invoice_items }
    it { should validate_numericality_of(:quantity).is_greater_than(0) }
    it { should validate_numericality_of(:percentage).is_greater_than(0) }
    it { should validate_numericality_of(:percentage).is_less_than_or_equal_to(100) }
  end
end
