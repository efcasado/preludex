defmodule Preludex.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Finch,
       name: Preludex.Finch,
       pools: %{
         :default => [
           size: 25,
           count: 1,
           protocols: [:http2]
         ]
       }}
    ]

    opts = [strategy: :one_for_one, name: Preludex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
