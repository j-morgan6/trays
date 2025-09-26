defmodule Trays.Repo do
  use Ecto.Repo,
    otp_app: :trays,
    adapter: Ecto.Adapters.Postgres
end
