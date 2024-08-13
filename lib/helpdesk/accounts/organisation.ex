defmodule Helpdesk.Accounts.Organisation do
  use Ash.Resource,
    domain: Helpdesk.Accounts,
    data_layer: AshPostgres.DataLayer

  defimpl Ash.ToTenant do
    def to_tenant(resource, %{:domain => domain, :id => id}) do
      if Ash.Resource.Info.data_layer(resource) == AshPostgres.DataLayer &&
           Ash.Resource.Info.multitenancy_strategy(resource) == :context do
        domain
      else
        id
      end
    end
  end

  postgres do
    table "organisations"
    repo Helpdesk.Repo

    manage_tenant do
      template ["", :domain]
      create? true
      update? false
    end
  end

  actions do
    defaults [:read, :destroy]

    create :create do
      accept [:name, :domain]
    end

    update :update do
      accept [:name]
    end

    read :by_id do
      argument :id, :string, allow_nil?: false
      get? true
      filter expr(id == ^arg(:id))
    end

    read :by_domain do
      argument :domain, :string, allow_nil?: false
      get? true
      filter expr(domain == ^arg(:domain))
    end
  end

  attributes do
    uuid_primary_key :id
    attribute :name, :string, allow_nil?: false
    attribute :domain, :string, allow_nil?: false
    attribute :went_live_at, :naive_datetime, allow_nil?: true
    attribute :email_domains, {:array, :string}, default: []

    timestamps()
  end

  identities do
    identity :unique_domain, [:domain]
  end
end
