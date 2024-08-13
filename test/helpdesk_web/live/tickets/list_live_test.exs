defmodule HelpdeskWeb.Tickets.ListLiveTest do
  use HelpdeskWeb.ConnCase
  import Phoenix.LiveViewTest

  def goto_page(conn) do
    live(conn, ~p"/tickets")
  end

  def create_tenant do
    Helpdesk.Accounts.create_organisation(%{name: "Tenant 1", domain: "tenant_1"})
  end

  describe "List tickes:" do
    test "1) User can visit /tickets and see a dropdown of organisations", %{conn: conn} do
      # 1. Create organisations as tenants
      1..5
      |> Enum.each(fn count -> create_tenant() end)

      # 2. Visit the page
      {:ok, _view, html} = goto_page(conn)

      # 2. Ensure the page is being rendered properly
      assert html =~ "Tickets"
    end

    test "2) User can select an existing organisation on the tickets", %{conn: conn} do
      # 2. Visit the page
      {:ok, view, html} = goto_page(conn)

      # 3. Ensure organisation created are listed in list options
    end

    test "3) User can select an organisation and list tickets under it", %{conn: conn} do
      # 1. Create organisations
      # 2. Create tickets under on organisation

      # 2. Visit the page
      {:ok, view, html} = goto_page(conn)

      # 3. Select one of the organisations

      # 4. Confirm the tickets under this organisations are listed
    end
  end
end
