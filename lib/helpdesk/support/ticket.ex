defmodule Helpdesk.Support.Ticket do
  use Ash.Resource,
    domain: Helpdesk.Support,
    notifiers: [Ash.Notifier.PubSub],
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

    update :close do
      accept []

      validate attribute_does_not_equal(:status, :close) do
        message "Ticket is already closed"
      end

      change set_attribute(:status, :closed)
    end
  end

  # This section is for pubsub broadcasting events that will automatically update the list
  pub_sub do
    module HelpdeskWeb.Endpoint
    prefix "tickets"

    publish :open, ["opened"]
    publish :close, ["closed"]
    publish :create, ["created"]
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
