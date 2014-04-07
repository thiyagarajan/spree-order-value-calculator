class Spree::Calculator::Shipping::OrderValue < Spree::ShippingCalculator
  preference :price_table, :text, default: "1:5\n2:7\n5:10\n10:15\n100:50"

  def self.description
    Spree.t(:ship_by_value)
  end

  def self.register
    super
  end

  def compute(package)
    order = package.order

    total_price, shipping = 0

    order.line_items.each do |item|
      total_price += item.price * item.quantity
    end
    costs = costs_string_to_hash

    costs.each do |cost_range, ship|
      shipping = ship if cost_range === total_price
    end
    return shipping
  end


  def costs_string_to_hash
    costs_string = self.preferred_price_table
    costs = {}
    initial_range = 0
    costs_string.split.each do |cost_string|
      values = cost_string.strip.split(':')
      costs[initial_range..values[0].strip.to_f] = values[1].strip.to_f
      initial_range = values[0].strip.to_f+0.01
    end
    costs
  end
end
