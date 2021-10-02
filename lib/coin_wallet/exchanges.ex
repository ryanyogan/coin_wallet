defmodule CoinWallet.Exchanges do
  alias CoinWallet.{Product, Trade}

  @clients [
    CoinWallet.Exchanges.CoinbaseClient,
    CoinWallet.Exchanges.BitstampClient
  ]

  @available_products (for client <- @clients, pair <- client.available_currency_pairs() do
                         Product.new(client.exchange_name(), pair)
                       end)

  @spec available_products :: [Product.t()]
  def available_products, do: @available_products

  @spec clients :: [module()]
  def clients, do: @clients

  @spec subscribe(Product.t()) :: :ok | {:error, term()}
  def subscribe(product) do
    Phoenix.PubSub.subscribe(CoinWallet.PubSub, topic(product))
  end

  @spec unsubscribe(Product.t()) :: :ok | {:error, term()}
  def unsubscribe(product) do
    Phoenix.PubSub.unsubscribe(CoinWallet.PubSub, topic(product))
  end

  @spec broadcast(Trade.t()) :: :ok | {:error, term()}
  def broadcast(trade) do
    Phoenix.PubSub.broadcast(
      CoinWallet.PubSub,
      topic(trade.product),
      {:new_trade, trade}
    )
  end

  @spec topic(Product.t()) :: String.t()
  def topic(product) do
    to_string(product)
  end
end
