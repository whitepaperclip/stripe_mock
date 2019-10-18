defmodule StripeMock.Database do
  @moduledoc """
  Start the database and hold the Repo config in its state.
  """

  use GenServer

  def start_link(arg) do
    GenServer.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def ecto_config() do
    GenServer.call(__MODULE__, :config)
  end

  @impl true
  def init(_) do
    {uri, _} = System.cmd("pg_tmp", ["-t"])

    [[username, host, port, database]] =
      Regex.scan(~r/(\w+)@([\w\d\.]+)\:(\d+)\/(\w+)/i, uri, capture: :all_but_first)

    config = [
      username: username,
      password: "",
      database: database,
      hostname: host,
      port: port,
      pool_size: 2,
      migration_primary_key: [type: :string]
    ]

    {:ok, config}
  end

  @impl true
  def handle_call(:config, _from, state) do
    {:reply, state, state}
  end
end