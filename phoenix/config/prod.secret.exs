use Mix.Config

# In this file, we keep production configuration that
# you likely want to automate and keep it away from
# your version control system.
config :pete_phoenix, PetePhoenix.Endpoint,
  secret_key_base: "CMZTPQcD/iyW9dVz+HXcOg1RRiBBC51UVcj9OSkoCuFtYgxVROlfWF/yD1xcPLdS"

# Configure your database
config :pete_phoenix, PetePhoenix.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "pete_phoenix_prod",
  pool_size: 20
