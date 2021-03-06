defmodule StripeMock.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      StripeMock.Database,
      StripeMock.Repo,
      StripeMock.Migrator,
      StripeMockWeb.Endpoint
    ]

    opts = [strategy: :one_for_one, name: StripeMock.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def config_change(changed, _new, removed) do
    StripeMockWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
