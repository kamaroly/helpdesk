defmodule HelpdeskWeb.Tickets.ListLiveTest do
  use HelpdeskWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Helpdesk.Accounts
  alias Helpdesk.Support

  def goto_page(conn) do
    live(conn, ~p"/tickets")
  end

  def create_tenant(tenant \\ %{name: "Tenant 1", domain: "tenant_1"}) do
    Accounts.create_organisation(tenant)
  end

  def create_tenants(count) do
    Enum.each(1..count, fn count ->
      create_tenant(%{name: "Tenant #{count}", domain: "tenant_#{count}"})
    end)
  end

  def create_ticket(tenant) do
    Support.open_ticket(%{subject: "Ticket 1"}, tenant: tenant)
  end

  describe "List tickes:" do
    test "1) User can visit /tickets and see a dropdown of organisations", %{conn: conn} do
      # 1. Create organisations as tenants
      create_tenants(5)

      # 2. Visit the page
      {:ok, _view, html} = goto_page(conn)

      # 2. Ensure the page is being rendered properly
      assert html =~ "Tickets"
    end

    test "2) User can select an existing organisation on the tickets", %{conn: conn} do
      # 1. Create organisations
      create_tenants(5)
      create_ticket("tenant_3")

      # 2. Visit the page
      {:ok, view, _html} = goto_page(conn)

      # 3. Ensure organisation created are listed in list options
      html =
        view
        |> element("#select-tenant")
        |> render_change(%{tenant: "tenant_3"})

      # 4. Confirm that the ticket has been created
      assert html =~ "Ticket 1"

      # 5. Confirm no ticket is listed when a different organisation is selected

      html_2 =
        view
        |> element("#select-tenant")
        |> render_change(%{tenant: "tenant_1"})

      refute html_2 =~ "Ticket 1"
    end

    test "3) User can see create a new ticket from the listing page", %{conn: conn} do
      {:ok, _view, html} = goto_page(conn)
      assert html =~ "Open a ticket"
    end

    test "4) User can close an open ticket", %{conn: conn} do
      # 1. Seed database
      create_tenants(4)
      create_ticket("tenant_4")

      # 2. Go to page
      {:ok, view, _html} = goto_page(conn)

      # 3. List tickets

      view
      |> element("#select-tenant")
      |> render_change(%{tenant: "tenant_4"})

      html =
        view
        |> element("#close-ticket")
        |> render_click()

      # 4. Close ticket
      {:ok, [ticket]} = Support.list_tickets(tenant: "tenant_4")

      assert ticket.status == :closed
      refute ticket.status == :open

      assert html =~ "Ticket no. #{ticket.id} closed."
    end
  end
end
