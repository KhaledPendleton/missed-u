defmodule MissedU.Connections do
  alias MissedU.Connections.Profile
  alias MissedU.{Repo, Accounts}

  def create_profile(user, attrs) do
    %Profile{}
    |> Profile.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  def load_profile(%Accounts.User{} = user) do
    Repo.preload(user, [:profile])
  end
end
