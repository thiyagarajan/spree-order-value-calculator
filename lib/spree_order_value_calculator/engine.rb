module SpreeOrderValue
  class Engine < Rails::Engine
    isolate_namespace Spree
    engine_name 'spree_order_value_calculator'

    config.autoload_paths += %W(#{config.root}/lib)

    initializer 'spree.register.calculators' do |app|
      require 'spree/calculator/shipping/order_value'
      app.config.spree.calculators.shipping_methods << Spree::Calculator::Shipping::OrderValue
    end
  end
end