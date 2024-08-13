defmodule HelpdeskWeb.Tickets.CreateLiveTest do
  use HelpdeskWeb.ConnCase
  import Phoenix.LiveViewTest

  def goto_page(conn) do
    live(conn, ~p"/tickets/open")
  end

  def create_tenant do
    Helpdesk.Accounts.create_organisation(%{name: "Tenant 1", domain: "tenant_1"})
  end

  describe "Create Ticket" do
    test "User should see open ticket form when visiting /tickes/open", %{conn: conn} do
      # 1. Go to /tickets/open
      {:ok, _view, html} = goto_page(conn)

      # 2. See the "Open Ticket" text on the page
      assert html =~ "Open Ticket"
      # 3. See Subject input on the page
      assert html =~ "name=\"form[subject]\""
      # 4. See Tenant lists on the page
      assert html =~ "name=\"form[tenant]\""
      # 5. See Submit button on the page
      assert html =~ "Open"
    end

    test "User should be see errors while trying to submit invalid data", %{conn: conn} do
      # 1. Create an organisation
      {:ok, tenant} = create_tenant()

      # 2. Go to /tickets/open page
      {:ok, view, _html} = goto_page(conn)

      # 3. Submit invalid form
      invalid_form = %{subject: "", tenant: tenant.domain}

      html =
        view
        |> form("#ticket-form", form: invalid_form)
        |> render_change()

      # 4. Expect to see error message on the page
      assert html =~ "is required"
    end

    test "User should successfully open a ticket with valid data", %{conn: conn} do
      # 1. Create an organisation
      {:ok, organisation} = create_tenant()

      # 2. Go to /tickets/open page
      {:ok, view, _html} = goto_page(conn)

      # 3. Fill the subject and submit the form
      form = %{subject: "Desktop not starting", tenant: organisation.domain}
      html = view |> form("#ticket-form", form: form) |> render_submit()

      # 4. Expect to not see error message on the page
      refute html =~ "is required"
      # <-- Confirm that user is notified
      assert html =~ "Ticket opened!"

      # 5. Expect data to be stored in the right tenant in the DB
      {:ok, tickets} = Helpdesk.Support.list_tickets(tenant: organisation.domain)
      ticket = Enum.at(tickets, 0)

      assert Enum.count(tickets) == 1
      assert ticket.subject == form.subject
    end
  end
end
