class Discount < ApplicationRecord
  belongs_to :merchant

  validates_presence_of :quantity, :percentage
end
