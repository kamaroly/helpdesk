defmodule Helpdesk.Support do
  use Ash.Domain

  alias Helpdesk.Support.Ticket

  resources do
    resource Ticket do
      define :open_ticket, action: :open
      define :list_tickets, action: :read
      define :update_ticket, action: :update
      # <-- Add line
      define :destroy_ticket, action: :destroy
    end
  end
end
