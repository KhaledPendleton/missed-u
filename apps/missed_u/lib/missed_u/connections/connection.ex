defmodule MissedU.Connections.Connection do
  use Ecto.Schema
  import Ecto.Changeset

  schema "connections" do
    belongs_to :profile_one, MissedU.Connections.Profile
    belongs_to :profile_two, MissedU.Connections.Profile

    timestamps()
  end

  def changeset(connection, attrs) do
    connection
    |> cast(attrs, [])
    |> validate_required([])
  end
end
