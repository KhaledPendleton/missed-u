defmodule MissedU.Connections do
  alias MissedU.Connections.{Profile, Trace}
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

  def create_trace(%{"author_profile" => profile} = attrs) do
    %Trace{}
    |> Trace.coordinate_changeset(attrs)
    |> Trace.associate_author(profile)
    |> Repo.insert!()
  end

  @search_radius_in_meters 50

  def nearby_traces(latitude, longitude) when is_float(latitude) and is_float(longitude) do
    Repo.all(Trace.in_radius_query(Trace, latitude, longitude, @search_radius_in_meters))
  end

  def unlock_nearby(latitude, longitude, key)
    when is_float(latitude) and is_float(longitude) and is_binary(key) do

      Trace
      |> Trace.in_radius_query(latitude, longitude, @search_radius_in_meters)
      |> Trace.unlocked_query(key)
      |> Repo.all()
  end
end
