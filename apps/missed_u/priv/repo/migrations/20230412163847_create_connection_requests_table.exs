defmodule MissedU.Repo.Migrations.CreateConnectionRequestsTable do
  use Ecto.Migration

  def change do
    create table(:connection_requests) do
      add :answered_at, :utc_datetime_usec
      add :request_maker_id, references(:profiles, on_delete: :delete_all), null: false
      add :recipient_id, references(:profiles, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:connection_requests, [:request_maker_id, :recipient_id])
  end
end
