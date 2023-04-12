defmodule MissedU.Connections.Trace do
  use Ecto.Schema
  import Ecto.Changeset

  schema "traces" do
    field :key, :string
    field :photo_url, :string

    belongs_to :author, MissedU.Connections.Profile

    timestamps([updated_at: false])
  end

  def changeset(trace, attrs) do
    trace
    |> cast(attrs, [:key, :photo_url])
    |> validate_required([:key, :photo_url])
  end
end
