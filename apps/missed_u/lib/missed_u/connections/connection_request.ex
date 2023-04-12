defmodule MissedU.Connections.ConnectionRequest do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connection_requests" do
    field :answered_at, :utc_datetime_usec

    belongs_to :request_maker, MissedU.Connections.Profile
    belongs_to :recipient, MissedU.Connections.Profile

    timestamps()
  end

  def changeset(connection_request, attrs) do
    connection_request
    |> cast(attrs, [])
    |> validate_required([])
  end
end
