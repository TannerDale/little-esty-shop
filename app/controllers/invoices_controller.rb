# frozen_string_literal: true

class InvoicesController < ApplicationController
  before_action :current_merchant

  def index
    @invoices = @merchant.ordered_invoices
  end

  def show
    @invoice = Invoice.find(params[:id])
    @discounts = @invoice.discounts_and_discounted_total
  end
end
