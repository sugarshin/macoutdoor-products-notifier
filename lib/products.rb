require "json"
require "./lib/product"

class Products
  attr_reader :products

  def initialize(products)
    @products = products
  end

  def self.from_json(json)
    parsed = JSON.parse json
    products = parsed["products"].map { |p| Product.new p }
    new products
  end

  def generate_json(d = Time.now)
    JSON.generate({
      date: d,
      products: to_h
    })
  end

  def pick_products_restock_from(json)
    if json.nil?
      return []
    end
    products_b = self.class.from_json json
    @products.each_with_object([]) { |product, r|
      found = products_b.products.find { |p| p.id == product.id }
      if found
        if !found.is_available && product.is_available
          r.push product
        end
      end
    }
  end

  def pick_products_new_from(json)
    if json.nil?
      return []
    end
    products_b = self.class.from_json json
    @products.each_with_object([]) { |product, r|
      found = products_b.products.find { |p| p.id == product.id }
      if !found
        r.push product
      end
    }
  end

  private

  def to_h
    @products.map { |p| p.instance_values }
  end
end
