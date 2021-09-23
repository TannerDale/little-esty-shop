class DiscountsController < ApplicationController
  before_action :current_merchant
  before_action :current_discount, except: %i[index new create]

  def index
    @discounts = Discount.all
    @next_holidays = HolidayService.next_three
  end

  def show; end

  def new
    @discount = Discount.new
  end

  def create
    discount = Discount.new(discount_params.merge({ merchant_id: params[:merchant_id] }))
    if discount.save
      flash[:success] = 'Discount Created'
      redirect_to merchant_discounts_path(@merchant)
    else
      flash[:alert] = 'Creation Failed'
      redirect_to new_merchant_discount_path
    end
  end

  def edit; end

  def update
  end

  def destroy
    @discount.destroy

    redirect_to merchant_discounts_path(@merchant)
  end

  private

  def discount_params
    params.require(:discount).permit(:quantity, :percentage)
  end

  def current_discount
    @discount = Discount.find(params[:id])
  end
end
