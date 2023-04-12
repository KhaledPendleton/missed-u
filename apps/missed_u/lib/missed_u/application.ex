defmodule MissedU.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      MissedU.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: MissedU.PubSub},
      # Start Finch
      {Finch, name: MissedU.Finch}
      # Start a worker by calling: MissedU.Worker.start_link(arg)
      # {MissedU.Worker, arg}
    ]

    Supervisor.start_link(children, strategy: :one_for_one, name: MissedU.Supervisor)
  end
end
