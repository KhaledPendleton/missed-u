defmodule MissedU.Connections.Trace do
  use Ecto.Schema

  import Ecto.{Changeset, Query}
  import Geo.PostGIS

  schema "traces" do
    field :key, :string
    field :photo_url, :string
    field :coordinates, Geo.PostGIS.Geometry

    belongs_to :author, MissedU.Connections.Profile,
      foreign_key: :author_id,
      references: :id

    timestamps([updated_at: false])
  end

  def changeset(trace, attrs) do
    trace
    |> cast(attrs, [:key, :photo_url])
    |> validate_required([:key, :photo_url])
  end

  def coordinate_changeset(trace, attrs) do
    trace
    |> changeset(attrs)
    |> cast_coordinates(attrs)
  end

  def associate_author(changeset, profile) do
    put_assoc(changeset, :author, profile)
  end

  def in_radius_query(queryable, latitude, longitude, radius_in_meters) do
    center = geo_point(latitude, longitude)

    from(
      t in queryable,
      where: st_dwithin_in_meters(t.coordinates, ^center, ^radius_in_meters))
  end

  def unlocked_query(queryable, key) do
    from(
      t in queryable,
      where: t.key == ^key
    )
  end

  defp cast_coordinates(changeset, attrs) do
    latitude = Map.fetch!(attrs, "latitude")
    longitude = Map.fetch!(attrs, "longitude")

    put_change(changeset, :coordinates, geo_point(latitude, longitude))
  end

  defp geo_point(latitude, longitude) do
    %Geo.Point{coordinates: {longitude, latitude}, srid: 4326}
  end
end
