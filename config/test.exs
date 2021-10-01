import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :coin_wallet, CoinWalletWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "1UiRt6RVFwwmBEwF6IQczcDKlhksV/m8e5+oeS6SyfjkarvC4pK/vQAqiq8S/6hB",
  server: false

# In test we don't send emails.
config :coin_wallet, CoinWallet.Mailer,
  adapter: Swoosh.Adapters.Test

# Print only warnings and errors during test
config :logger, level: :warn

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
