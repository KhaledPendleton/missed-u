defmodule MissedU.Repo do
  use Ecto.Repo,
    otp_app: :missed_u,
    adapter: Ecto.Adapters.Postgres
end
