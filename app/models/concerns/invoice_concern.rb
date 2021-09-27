module InvoiceConcern
  extend ActiveSupport::Concern
  extend self

  def discount_and_total
    inv_item_discounts.group_by(&:id).map do |inv_id, discount|
      max_d = discount.max_by(&:percentage)
      amount_off = max_d.revenue * max_d.percentage.fdiv(100)

      discount_info = {
        id: max_d.discount,
        amount_off: amount_off
      }

      [inv_id, discount_info]
    end.to_h
  end

  def discounted_info
    result = discount_and_total
    price_off = result.sum do |_inv, dis|
      dis[:amount_off]
    end
    result.merge({ discounted_total: total_revenue - price_off })
  end
end
