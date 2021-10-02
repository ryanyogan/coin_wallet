defmodule CoinWallet.Application do
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CoinWalletWeb.Telemetry,
      {Phoenix.PubSub, name: CoinWallet.PubSub},
      {CoinWallet.Historical, name: CoinWallet.Historical},
      {CoinWallet.Exchanges.Supervisor, name: CoinWallet.Exchanges.Supervisor},
      CoinWalletWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: CoinWallet.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    CoinWalletWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
