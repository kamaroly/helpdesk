defmodule HelpdeskWeb.Tickets.ListLive do
  alias Helpdesk.Support
  use HelpdeskWeb, :live_view
  alias Helpdesk.Accounts

  def render(assigns) do
    ~H"""
    <.header>Tickets</.header>

    <div>
      <.link
        navigate={~p"/tickets/open"}
        class={[
          "phx-submit-loading:opacity-75 rounded-lg bg-zinc-900 hover:bg-zinc-700 py-2 px-3",
          "text-sm font-semibold leading-6 text-white active:text-white/80"
        ]}
      >
        Open a ticket
      </.link>
    </div>

    <.simple_form for={@form} id="select-tenant-form">
      <.input
        name="tenant"
        id="select-tenant"
        type="select"
        label="Select Tenant"
        value=""
        prompt="Select Organisation"
        phx-change="select-tenant"
        options={Enum.map(@organisations, fn tenant -> {tenant.name, tenant.domain} end)}
      />
    </.simple_form>

    <.list>
      <:item :for={ticket <- @tickets} title={ticket.subject}>
        <%= ticket.status %>
        <.button id="close-ticket" phx-click="close-ticket" phx-value-id={ticket.id}>
          Close Ticket
        </.button>
      </:item>
    </.list>
    """
  end

  def mount(_params, _session, socket) do
    if connected?(socket) do
      HelpdeskWeb.Endpoint.subscribe("tickets:opened")
      HelpdeskWeb.Endpoint.subscribe("tickets:closed")
      HelpdeskWeb.Endpoint.subscribe("tickets.created")
    end

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
      |> assign(:tenant, tenant)

    {:noreply, socket}
  end

  def handle_event("close-ticket", %{"id" => ticket_id}, socket) do
    tenant = socket.assigns.tenant

    case Support.close_ticket(ticket_id, tenant: tenant) do
      {:ok, ticket} ->
        socket =
          socket
          |> put_flash(:info, "Ticket no. #{ticket.id} closed.")

        {:noreply, socket}

      {:error, _form} ->
        socket
        |> put_flash(:error, "Unable to close ticket: ticket_id")

        {:noreply, socket}
    end
  end

  def handle_info(%Phoenix.Socket.Broadcast{topic: topic}, socket) do
    {:ok, tickets} = Support.list_tickets(tenant: socket.assigns.tenant)

    socket = assign(socket, :tickets, tickets)
    {:noreply, socket}
  end
end
