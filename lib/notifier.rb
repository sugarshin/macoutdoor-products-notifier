require "slack-ruby-client"

class Notifier
  def initialize(new_products, restock_products)
    Slack.configure { |c|
      c.token = ENV["SLACK_BOT_USER_OAUTH_TOKEN"]
    }
    @client = Slack::Web::Client.new
    @new_products = new_products
    @restock_products = restock_products
  end

  def notify
    if @new_products.length > 0 || @restock_products.length > 0
      res = @client.chat_postMessage(
        channel: (ENV["SLACK_CHANNEL"]).to_s,
        text: "Mac Outdoor 入荷情報"
      )

      @new_products.each { |product|
        @client.chat_postMessage(
          channel: (ENV["SLACK_CHANNEL"]).to_s,
          text: "NEW!!!\n> <#{product.url}|#{product.name}>",
          thread_ts: res[:ts]
        )
      }

      @restock_products.each { |product|
        @client.chat_postMessage(
          channel: (ENV["SLACK_CHANNEL"]).to_s,
          text: "再入荷!!!\n> <#{product.url}|#{product.name}>",
          thread_ts: res[:ts]
        )
      }
    else
      puts "there are no new arrivals."
    end
  end
end
