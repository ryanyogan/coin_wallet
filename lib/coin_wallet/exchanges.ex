defmodule CoinWallet.Exchanges do
  alias CoinWallet.{Product, Trade}

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
