# frozen_string_literal: true

class Transaction < ApplicationRecord
  belongs_to :invoice

  enum result: %w[success failed]
end
