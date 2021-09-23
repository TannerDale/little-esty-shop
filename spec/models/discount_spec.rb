require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations/relationships' do
    it { should belong_to :merchant }
    it { should validate_presence_of :quantity }
    it { should validate_presence_of :percentage }
  end
end
