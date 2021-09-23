require 'rails_helper'

RSpec.describe Discount, type: :model do
  describe 'validations/relationships' do
    it { should belong_to :merchant }
  end
end
