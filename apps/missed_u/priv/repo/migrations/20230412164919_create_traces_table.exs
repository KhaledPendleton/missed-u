defmodule MissedU.Repo.Migrations.CreateTracesTable do
  use Ecto.Migration

  def change do
    create table(:traces) do
      add :key, :string, null: false
      add :photo_url, :string, null: false
      add :author_id, references(:profiles, on_delete: :delete_all), null: false

      timestamps([updated_at: false])
    end

    create index(:traces, [:key])
    create index(:traces, [:author_id])

    execute("SELECT AddGeometryColumn('traces', 'coordinates', 4326, 'POINT', 2)")
    execute("CREATE INDEX trace_coordinates_index on traces USING gist (coordinates)")
  end
end
