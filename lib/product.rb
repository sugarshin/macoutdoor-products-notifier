class Product
  attr_reader :id, :url, :name, :is_available

  NOT_AVAILABLE = "在庫なし"
  ADD_TO_CART = "カートに追加する"

  def initialize(data)
    @id = data["id"]
    @name = data["name"]
    @url = data["url"]
    @is_available = data["is_available"]
  end

  def self.from_node(node)
    a = node.css("> a")
    url = a.attr("href").to_s
    id = url
    name = a.css("h3").inner_text.to_s
    is_available = node.css("> div button").inner_text.to_s == ADD_TO_CART
    new(
      "id" => id,
      "name" => name,
      "url" => url,
      "is_available" => is_available
    )
  end
end
