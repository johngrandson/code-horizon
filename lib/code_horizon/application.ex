defmodule CodeHorizon.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      CodeHorizonWeb.Telemetry,
      CodeHorizon.Repo,
      {DNSCluster, query: Application.get_env(:code_horizon, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: CodeHorizon.PubSub},
      CodeHorizonWeb.Presence,
      {Task.Supervisor, name: CodeHorizon.BackgroundTask},
      # Start the Finch HTTP client for sending emails and Tesla
      {Finch, name: CodeHorizon.Finch},
      {Oban, Application.fetch_env!(:code_horizon, Oban)},
      # Start a worker by calling: CodeHorizon.Worker.start_link(arg)
      # {CodeHorizon.Worker, arg}
      # Start to serve requests, typically the last entry
      CodeHorizonWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: CodeHorizon.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    CodeHorizonWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
