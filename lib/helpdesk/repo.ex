defmodule Helpdesk.Repo do
  use AshPostgres.Repo,
    otp_app: :helpdesk

  def installed_extensions do
    # Add extensions here, and the migration generator will install them.
    ["ash-functions", "uuid-ossp", "citext"]
  end

  @doc """
  Used by migrations --tenants to list all tenants, create related schemas and migrates
  """
  def all_tenants do
    for org <- Helpdesk.Accounts.list_organisations!() do
      org.domain
    end
  end
end
