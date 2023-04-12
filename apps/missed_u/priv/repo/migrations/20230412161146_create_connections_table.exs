defmodule MissedU.Repo.Migrations.CreateConnectionsTable do
  use Ecto.Migration

  def change do
    create table(:connections) do
      add :profile_one_id, references(:profiles, on_delete: :delete_all), null: false
      add :profile_two_id, references(:profiles, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:connections, [:profile_one_id, :profile_two_id])
  end
end
