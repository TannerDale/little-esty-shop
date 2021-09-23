class DiscountsController < ApplicationController
  before_action :current_merchant
  before_action :current_discount, except: %i[index new create]

  def index
    @discounts = Discount.all
    @next_holidays = HolidayService.next_three
  end

  def show; end

  def new
  end

  def create
  end

  def edit; end

  def update
  end

  def destroy
  end

  private

  def current_discount
    @discount = Discount.find(params[:id])
  end
end
