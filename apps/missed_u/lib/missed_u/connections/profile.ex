defmodule MissedU.Connections.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    field :name, :string
    field :avatar_url, :string

    belongs_to :user, MissedU.Accounts.User

    has_many :traces, MissedU.Connections.Trace,
      foreign_key: :author_id,
      references: :id

    timestamps()
  end

  def changeset(profile, attrs) do
    profile
    |> cast(attrs, [:name, :avatar_url])
    |> validate_required([:name])
  end
end
