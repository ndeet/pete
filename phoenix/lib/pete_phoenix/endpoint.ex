defmodule PetePhoenix.Endpoint do
  use Phoenix.Endpoint, otp_app: :pete_phoenix

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :pete_phoenix, gzip: false,
    only: ~w(css fonts images js favicon.ico robots.txt)

  plug PetePhoenix.Router
end
