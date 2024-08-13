defmodule Helpdesk.Accounts do
  use Ash.Domain

  alias Helpdesk.Accounts.Organisation

  resources do
    # We'll add our resources here in a moment
    resource Organisation do
      define :create_organisation, action: :create
      define :list_organisations, action: :read
      define :update_organisation, action: :update
      define :destroy_organisation, action: :destroy
      define :get_organisation_by_id, args: [:id], action: :by_id
      define :get_organisation_by_domain, args: [:domain], action: :by_domain
    end
  end
end
