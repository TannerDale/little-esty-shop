# frozen_string_literal: true

class Transaction < ApplicationRecord
  self.primary_key = :id

  belongs_to :invoice

  enum result: %w[success failed]
end
