defmodule CoinWalletWeb.ProductController do
  use CoinWalletWeb, :controller

  def index(conn, _params) do
    trades =
      CoinWallet.available_products()
      |> CoinWallet.get_last_trades()

    render(conn, "index.html", trades: trades)
  end
end
