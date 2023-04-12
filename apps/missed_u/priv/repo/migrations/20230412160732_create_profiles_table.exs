defmodule MissedU.Repo.Migrations.CreateProfilesTable do
  use Ecto.Migration

  # TODO: Account for age

  def change do
    create table(:profiles) do
      add :name, :string, null: false
      add :avatar_url, :string

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:profiles, [:user_id])
  end
end
