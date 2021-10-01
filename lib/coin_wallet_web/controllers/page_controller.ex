defmodule CoinWalletWeb.PageController do
  use CoinWalletWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
