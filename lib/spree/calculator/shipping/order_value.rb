class Spree::Calculator::Shipping::OrderValue < Spree::ShippingCalculator
  preference :price_table, :text, default: "1:5\n2:7\n5:10\n10:15\n100:50"

  def self.description
    Spree.t(:ship_by_value)
  end

  def self.register
    super
  end

  # as order_or_line_items we always get line items, as calculable we have Coupon, ShippingMethod or ShippingRate
  def compute(package)
    order = package.order

    total_price, total_weight, shipping = 0, 0, 0
    prices = self.preferred_price_table.split.map { |price| price.to_f }

    order.line_items.each do |item| # determine total price and weight
      total_weight += item.quantity * (item.variant.weight || self.preferred_default_weight)
      total_price += item.price * item.quantity
    end

    return 0.0 if total_price > self.preferred_max_price

    # determine handling fee
    handling_fee = self.preferred_handling_max < total_price ? 0 : self.preferred_handling_fee
    weights = self.preferred_weight_table.split.map { |weight| weight.to_f }

    while total_weight > weights.last # in several packages if need be
      total_weight -= weights.last
      shipping += prices.last
    end

    index = weights.length - 2
    while index >= 0
      break if total_weight > weights[index]
      index -= 1
    end

    shipping += prices[index + 1]
    return shipping + handling_fee
  end
end
