defmodule CoinWallet.Test.HistoricalTest do
  use ExUnit.Case, async: true
  alias CoinWallet.{Historical, Exchanges, Trade, Product}

  setup :start_fresh_historical_with_all_products
  setup :start_fresh_historical_with_all_coinbase_products
  setup :start_historical_with_trades_for_all_products

  describe "get_last_trade/2" do
    test "gets the most recent trade for a product", %{all_history: historical} do
      product = Product.new("coinbase", "BTC-USD")
      assert nil == Historical.get_last_trade(historical, product)

      trade = build_valid_trade(product)
      broadcast_trade(trade)
      assert trade == Historical.get_last_trade(historical, product)

      new_trade = build_valid_trade(product)
      assert :gt == DateTime.compare(new_trade.traded_at, trade.traded_at)

      broadcast_trade(new_trade)
      assert new_trade == Historical.get_last_trade(historical, product)
    end
  end

  describe "get_last_trades/2" do
    test "given a list of products, returns a list of most recent trades",
         %{history_with_trades: history} do
      products =
        Exchanges.available_products()
        |> Enum.shuffle()

      assert products ==
               history
               |> Historical.get_last_trades(products)
               |> Enum.map(fn %Trade{product: p} -> p end)
    end

    test "nil in the returned list when the Historical doesn't have a trade for a product",
         %{history_with_trades: history} do
      products = [
        Product.new("coinbase", "BTC-USD"),
        Product.new("coinbase", "invalid_pair"),
        Product.new("bitstamp", "btcusd")
      ]

      assert [%Trade{}, nil, %Trade{}] = Historical.get_last_trades(history, products)
    end
  end

  test "keeps track of the trades for only the :products passed when started",
       %{coinbase_history: coinbase_history} do
    coinbase_product = coinbase_btc_usd_product()
    bitstamp_product = bitstamp_btc_usd_product()

    assert nil == Historical.get_last_trade(coinbase_history, bitstamp_product)

    bitstamp_product
    |> build_valid_trade()
    |> broadcast_trade()

    assert nil == Historical.get_last_trade(coinbase_history, bitstamp_product)
    assert nil == Historical.get_last_trade(coinbase_history, coinbase_product)

    coinbase_trade = build_valid_trade(coinbase_product)
    broadcast_trade(coinbase_trade)
    assert coinbase_trade == Historical.get_last_trade(coinbase_history, coinbase_product)
  end

  defp all_products, do: Exchanges.available_products()
  defp broadcast_trade(trade), do: Exchanges.broadcast(trade)
  defp coinbase_btc_usd_product, do: Product.new("coinbase", "BTC-USD")
  defp bitstamp_btc_usd_product, do: Product.new("bitstamp", "btcusd")

  defp all_coinbase_products do
    Exchanges.available_products()
    |> Enum.filter(&(&1.exchange_name == "coinbase"))
  end

  defp build_valid_trade(product) do
    %Trade{
      product: product,
      traded_at: DateTime.utc_now(),
      price: "1.00",
      volume: "0.10000"
    }
  end

  defp start_fresh_historical_with_all_products(_ctx) do
    {:ok, all_history} = Historical.start_link(products: all_products())
    [all_history: all_history]
  end

  defp start_fresh_historical_with_all_coinbase_products(_ctx) do
    {:ok, coinbase_history} = Historical.start_link(products: all_coinbase_products())
    [coinbase_history: coinbase_history]
  end

  defp start_historical_with_trades_for_all_products(_cts) do
    products = all_products()
    {:ok, history_with_trades} = Historical.start_link(products: products)
    Enum.each(products, &send(history_with_trades, {:new_trade, build_valid_trade(&1)}))
    [history_with_trades: history_with_trades]
  end
end
