defmodule Helpdesk.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HelpdeskWeb.Telemetry,
      Helpdesk.Repo,
      {DNSCluster, query: Application.get_env(:helpdesk, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Helpdesk.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Helpdesk.Finch},
      # Start a worker by calling: Helpdesk.Worker.start_link(arg)
      # {Helpdesk.Worker, arg},
      # Start to serve requests, typically the last entry
      HelpdeskWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Helpdesk.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HelpdeskWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
