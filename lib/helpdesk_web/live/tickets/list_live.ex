defmodule HelpdeskWeb.Tickets.ListLive do
  alias Helpdesk.Support
  use HelpdeskWeb, :live_view
  alias Helpdesk.Accounts

  def render(assigns) do
    ~H"""
    <.header>Tickets</.header>

    <.simple_form for={@form}>
      <.input
        name="tenant"
        type="select"
        label="Select Tenant"
        value=""
        prompt="Select Organisation"
        phx-change="select-tenant"
        options={Enum.map(@organisations, fn tenant -> {tenant.name, tenant.domain} end)}
      />
    </.simple_form>

    <.list>
      <:item :for={ticket <- @tickets} title={ticket.subject}><%= ticket.status %></:item>
    </.list>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, organisations} = Accounts.list_organisations()

    socket =
      socket
      |> assign(:organisations, organisations)
      |> assign(:form, to_form(%{}))
      |> assign(:tickets, [])

    {:ok, socket}
  end

  def handle_event("select-tenant", %{"tenant" => tenant}, socket) do
    {:ok, tickets} = Support.list_tickets(tenant: tenant)

    socket =
      socket
      |> assign(:tickets, tickets)

    {:noreply, socket}
  end
end
