# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Transaction, type: :model do
  describe 'relationships' do
    let(:results) { %w[success failed] }
    let!(:transaction) { create :transaction, { result: 0 } }

    it { should belong_to :invoice }

    it 'has the right index' do
      results.each_with_index do |item, index|
        expect(Transaction.results[item]).to eq(index)
      end
    end

    it 'successful scope returns successful results' do
      expect(Transaction.success).to eq([transaction])
    end
  end
end
