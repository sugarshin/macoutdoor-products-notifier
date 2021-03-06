require "dotenv/load"
require "active_support"
require "active_support/core_ext"
require "open-uri"
require "fake_useragent"
require "nokogiri"
require "./lib/product"
require "./lib/products"
require "./lib/notifier"

products_json_path = ARGV[0]
if !products_json_path
  puts "products_json_path is requied"
  exit 1
end

LIMIT = rand(8..20)
uri = "https://www.macoutdoorjapan.info/blank-1?page=#{LIMIT}"
charset = nil
begin
  puts "start to request to #{uri}"
  html = URI.parse(uri).open("User-Agent" => generate_user_agent) { |f|
    if f.status[0] != "200"
      puts "requested resource could not be accessed correctly"
      puts html
    end
    charset = f.charset
    f.read
  }
rescue => e
  p e
  exit 1
end

doc = Nokogiri::HTML5(html, nil, charset)

products = Products.new doc.css("ul[data-hook=product-list-wrapper] li div[data-hook=product-item-root]").map { |product_node|
  Product.from_node(product_node)
}
json = products.generate_json
if File.exist?(products_json_path)
  prev_json = File.read(products_json_path)
  puts "date: #{JSON.parse(prev_json)["date"]}"
else
  puts "could not find previous products_json"
end

# if 0, it may be could not be accessed correctly
if products.size != 0
  IO.write(products_json_path, json)
end

new_products = products.pick_products_new_from prev_json
restock_products = products.pick_products_restock_from prev_json
Notifier.new(new_products, restock_products).notify
