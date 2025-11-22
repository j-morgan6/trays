defmodule Trays.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    # Load environment variables from .env file in development
    load_env_file()

    children = [
      TraysWeb.Telemetry,
      Trays.Repo,
      {DNSCluster, query: Application.get_env(:trays, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Trays.PubSub},
      {Finch, name: Trays.Finch},
      # Start a worker by calling: Trays.Worker.start_link(arg)
      # {Trays.Worker, arg},
      # Start to serve requests, typically the last entry
      TraysWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Trays.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TraysWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  # Load environment variables from .env file
  defp load_env_file do
    # Check if running in dev or test mode
    if Code.ensure_loaded?(Mix) and Mix.env() in [:dev, :test] and File.exists?(".env") do
      Dotenvy.source([".env"])
    end
  end
end
