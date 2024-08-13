defmodule Helpdesk.Support.Ticket do
  use Ash.Resource,
    domain: Helpdesk.Support,
    data_layer: AshPostgres.DataLayer

  postgres do
    table "tickets"
    repo Helpdesk.Repo
  end

  actions do
    defaults [:read, :destroy]

    create :open do
      accept [:subject]
    end

    update :update do
      accept [:subject]
    end
  end

  # -- MULTI TENANCY SECTION
  multitenancy do
    strategy :context
  end

  # -- END OF MULTITENANT

  attributes do
    uuid_primary_key :id
    attribute :subject, :string, allow_nil?: false, public?: true

    attribute :status, :atom do
      constraints one_of: [:open, :close]
      default :open
      allow_nil? false
    end

    timestamps()
  end
end
