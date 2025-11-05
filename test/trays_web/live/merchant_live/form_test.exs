defmodule TraysWeb.MerchantLive.FormTest do
  use TraysWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Trays.AccountsFixtures
  import Trays.MerchantsFixtures

  describe "Merchant Form - Edit - Mount" do
    test "requires authentication", %{conn: conn} do
      assert {:error, {:redirect, %{to: "/users/log-in"}}} = live(conn, ~p"/merchants/123/edit")
    end

    test "mounts successfully for authenticated user with their merchant", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test Business"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Edit Business"
      assert html =~ "Test Business"
    end

    test "raises when user tries to edit another user's merchant", %{conn: conn} do
      user1 = user_fixture(%{type: :merchant})
      user2 = user_fixture(%{email: "other@example.com", type: :merchant})
      merchant2 = merchant_fixture(%{user: user2})
      conn = log_in_user(conn, user1)

      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchants/#{merchant2}/edit")
      end
    end

    test "displays existing merchant data in form", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Pizza Palace", description: "Best pizza in town"})

      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "value=\"Pizza Palace\""
      assert html =~ "Best pizza in town"
    end

    test "initializes character counters with existing data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test", description: "A description"})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      # "Test" is 4 characters
      assert html =~ "4/100"
      # "A description" is 13 characters
      assert html =~ "13/500"
    end
  end

  describe "Merchant Form - Validation" do
    test "validates form on change", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Clear the name field (invalid)
      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "updates character counter on input", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Test"})
      conn = log_in_user(conn, user)

      assert {:ok, view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "4/100"

      html =
        view
        |> form("#merchant-form", merchant: %{name: "New Business Name"})
        |> render_change()

      assert html =~ "17/100"
    end

    test "shows validation error for missing name", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: "", description: "Valid description"})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "shows validation error for missing description", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: ""})
        |> render_change()

      assert html =~ "can&#39;t be blank"
    end

    test "disables submit button when form is invalid", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "disabled"
      assert html =~ "cursor-not-allowed"
    end
  end

  describe "Merchant Form - Save" do
    test "updates merchant with valid data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Old Name"})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      assert view
             |> form("#merchant-form",
               merchant: %{name: "Updated Name", description: "Updated description"}
             )
             |> render_submit()

      assert_redirect(view, ~p"/merchants/#{merchant}")

      updated_merchant = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert updated_merchant.name == "Updated Name"
      assert updated_merchant.description == "Updated description"
    end

    test "does not update with invalid data", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user, name: "Original"})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_submit()

      assert html =~ "can&#39;t be blank"

      # Verify not changed in database
      unchanged_merchant = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert unchanged_merchant.name == "Original"
    end
  end

  describe "Merchant Form - Navigation" do
    test "shows back to dashboard link", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Back to Dashboard"
      assert html =~ "href=\"/merchants/#{merchant.id}\""
    end

    test "cancel button links back to merchants", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Cancel"
      assert html =~ "href=\"/merchants/#{merchant.id}\""
    end
  end

  describe "Merchant Form - Character Limits" do
    test "shows character counter for name over limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      long_name = String.duplicate("a", 101)

      html =
        view
        |> form("#merchant-form", merchant: %{name: long_name})
        |> render_change()

      # Character counter shows over limit (browser maxlength prevents actual save)
      assert html =~ "101/100"
      assert html =~ "text-red-600"
    end

    test "shows character counter for description over limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      long_description = String.duplicate("a", 501)

      html =
        view
        |> form("#merchant-form", merchant: %{description: long_description})
        |> render_change()

      # Character counter shows over limit (browser maxlength prevents actual save)
      assert html =~ "501/500"
      assert html =~ "text-red-600"
    end

    test "shows warning color when approaching character limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 90 characters (90% of 100)
      name_90_chars = String.duplicate("a", 90)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_90_chars})
        |> render_change()

      assert html =~ "90/100"
      assert html =~ "text-amber"
    end
  end

  describe "Merchant Form - UI Elements" do
    test "displays helper text for name field", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "This is your main business name displayed throughout the dashboard"
    end

    test "shows placeholder text for inputs", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Pizza Palace"
      assert html =~ "Describe your business"
    end

    test "marks required fields with asterisk", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")
      assert html =~ "Business Name"
      assert html =~ "text-red-500"
      assert html =~ "*"
    end
  end

  describe "Merchant Form - Return To Parameter" do
    test "defaults return_to to index when not provided", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      view
      |> form("#merchant-form", merchant: %{name: "Updated", description: "Updated desc"})
      |> render_submit()

      # Should redirect to show page (default)
      assert_redirect(view, ~p"/merchants/#{merchant}")
    end

    test "respects return_to=show parameter", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit?return_to=show")

      view
      |> form("#merchant-form", merchant: %{name: "Updated", description: "Updated desc"})
      |> render_submit()

      assert_redirect(view, ~p"/merchants/#{merchant}")
    end

    test "ignores invalid return_to parameter", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit?return_to=invalid")

      view
      |> form("#merchant-form", merchant: %{name: "Updated", description: "Updated desc"})
      |> render_submit()

      # Should still redirect to show (default behavior)
      assert_redirect(view, ~p"/merchants/#{merchant}")
    end
  end

  describe "Merchant Form - Character Count Classes" do
    test "shows default color when character count is 0", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Clear the name field to trigger 0 count
      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "0/100"
      assert html =~ "text-base-content/40"
    end

    test "shows normal color when under 75% of limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 50 characters (50% of 100)
      name_50_chars = String.duplicate("a", 50)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_50_chars})
        |> render_change()

      assert html =~ "50/100"
      assert html =~ "text-base-content/60"
    end

    test "shows amber color when at 75-89% of limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 80 characters (80% of 100)
      name_80_chars = String.duplicate("a", 80)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_80_chars})
        |> render_change()

      assert html =~ "80/100"
      assert html =~ "text-amber-500"
    end

    test "shows amber-600 semibold when at 90-99% of limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 95 characters (95% of 100)
      name_95_chars = String.duplicate("a", 95)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_95_chars})
        |> render_change()

      assert html =~ "95/100"
      assert html =~ "text-amber-600"
      assert html =~ "font-semibold"
    end

    test "shows red semibold when at or over limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 100 characters (100% of 100)
      name_100_chars = String.duplicate("a", 100)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_100_chars})
        |> render_change()

      assert html =~ "100/100"
      assert html =~ "text-red-600"
      assert html =~ "font-semibold"
    end
  end

  describe "Merchant Form - Input Classes" do
    test "shows error styling when field has errors", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html =~ "border-red-300"
      assert html =~ "bg-red-50"
    end

    test "shows success styling when field has valid value", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form",
          merchant: %{name: "Valid Name", description: "Valid Description"}
        )
        |> render_change()

      assert html =~ "border-emerald-300"
      assert html =~ "bg-emerald-50"
    end

    test "shows default styling when field is empty and no errors", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Initial load should have default styling for inputs
      assert html =~ "border-base-content/20"
      assert html =~ "bg-white"
    end
  end

  describe "Merchant Form - Edge Cases" do
    test "handles empty string values in character length calculation", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Submit form with empty strings
      html =
        view
        |> form("#merchant-form", merchant: %{name: "", description: ""})
        |> render_change()

      # Should not crash and should show 0 length
      assert html =~ "0/100"
      assert html =~ "0/500"
    end

    test "preserves existing data when validation fails", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Original Name", description: "Original Desc"})

      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      view
      |> form("#merchant-form", merchant: %{name: ""})
      |> render_submit()

      # Check database wasn't updated
      unchanged = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert unchanged.name == "Original Name"
      assert unchanged.description == "Original Desc"
    end

    test "handles description at exactly 75% of limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 375 characters (75% of 500)
      desc_375_chars = String.duplicate("a", 375)

      html =
        view
        |> form("#merchant-form", merchant: %{description: desc_375_chars})
        |> render_change()

      assert html =~ "375/500"
      # Should show amber-500 at exactly 75%
      assert html =~ "text-amber-500"
    end

    test "handles description at exactly 90% of limit", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      assert {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 450 characters (90% of 500)
      desc_450_chars = String.duplicate("a", 450)

      html =
        view
        |> form("#merchant-form", merchant: %{description: desc_450_chars})
        |> render_change()

      assert html =~ "450/500"
      # Should show amber-600 at exactly 90%
      assert html =~ "text-amber-600"
    end
  end

  describe "Merchant Form - Nil Value Handling" do
    test "handles nil name in character counter during validation", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Send validation event with params containing nil name
      # This tests the `merchant_params["name"] || ""` logic
      html =
        view
        |> element("#merchant-form")
        |> render_change(%{merchant: %{name: nil}})

      # Should handle nil gracefully and show 0 count
      assert html =~ "0/100"
    end

    test "handles nil description in character counter during validation", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> element("#merchant-form")
        |> render_change(%{merchant: %{description: nil}})

      # Should handle nil gracefully and show 0 count
      assert html =~ "0/500"
    end

    test "handles merchant with nil name during mount", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      # Create merchant through fixture which may have default name
      merchant = merchant_fixture(%{user: user})

      # Update to set name to nil directly in database
      merchant
      |> Ecto.Changeset.change(name: nil)
      |> Trays.Repo.update!()

      conn = log_in_user(conn, user)

      # Should handle nil name without crashing
      {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Counter should show 0 for nil name
      assert html =~ "0/100"
    end

    test "handles merchant with nil description during mount", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})

      # Update to set description to nil directly in database
      merchant
      |> Ecto.Changeset.change(description: nil)
      |> Trays.Repo.update!()

      conn = log_in_user(conn, user)

      {:ok, _view, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Counter should show 0 for nil description
      assert html =~ "0/500"
    end
  end

  describe "Merchant Form - Boundary Tests" do
    test "handles maximum name length exactly", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Exactly 100 characters
      exact_max_name = String.duplicate("a", 100)

      html =
        view
        |> form("#merchant-form", merchant: %{name: exact_max_name})
        |> render_change()

      assert html =~ "100/100"
      assert html =~ "text-red-600"
      assert html =~ "font-semibold"
    end

    test "handles maximum description length exactly", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Exactly 500 characters
      exact_max_desc = String.duplicate("a", 500)

      html =
        view
        |> form("#merchant-form", merchant: %{description: exact_max_desc})
        |> render_change()

      assert html =~ "500/500"
      assert html =~ "text-red-600"
      assert html =~ "font-semibold"
    end

    test "handles one character below 75% threshold", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 74 characters (just below 75% of 100)
      name_74_chars = String.duplicate("a", 74)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_74_chars})
        |> render_change()

      assert html =~ "74/100"
      # Should show normal color, not amber
      assert html =~ "text-base-content/60"
      refute html =~ "text-amber"
    end

    test "handles one character above 75% threshold", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 75 characters (exactly 75% of 100)
      name_75_chars = String.duplicate("a", 75)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_75_chars})
        |> render_change()

      assert html =~ "75/100"
      # Should show amber-500 at exactly 75%
      assert html =~ "text-amber-500"
    end

    test "handles one character below 90% threshold", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 89 characters (just below 90% of 100)
      name_89_chars = String.duplicate("a", 89)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_89_chars})
        |> render_change()

      assert html =~ "89/100"
      # Should show amber-500, not amber-600
      assert html =~ "text-amber-500"
      refute html =~ "text-amber-600"
    end

    test "handles one character below max threshold", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # 99 characters (just below 100)
      name_99_chars = String.duplicate("a", 99)

      html =
        view
        |> form("#merchant-form", merchant: %{name: name_99_chars})
        |> render_change()

      assert html =~ "99/100"
      # Should show amber-600 semibold, not red
      assert html =~ "text-amber-600"
      assert html =~ "font-semibold"
      refute html =~ "text-red-600"
    end
  end

  describe "Merchant Form - Input Validation Edge Cases" do
    test "shows error styling persists after fixing then breaking validation", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # First, make invalid
      html1 =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html1 =~ "border-red-300"

      # Then fix it
      html2 =
        view
        |> form("#merchant-form", merchant: %{name: "Valid Name"})
        |> render_change()

      assert html2 =~ "border-emerald-300"

      # Break it again
      html3 =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_change()

      assert html3 =~ "border-red-300"
    end

    test "validates both name and description simultaneously", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: "", description: ""})
        |> render_change()

      # Both fields should show errors
      assert html =~ "can&#39;t be blank"
      # Should have multiple error indicators
      assert html =~ "border-red-300"
    end

    test "allows update with only name changed", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Old Name", description: "Old Description Text"})

      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      view
      |> form("#merchant-form", merchant: %{name: "New Name"})
      |> render_submit()

      assert_redirect(view, ~p"/merchants/#{merchant}")

      updated = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert updated.name == "New Name"
      assert updated.description == "Old Description Text"
    end

    test "allows update with only description changed", %{conn: conn} do
      user = user_fixture(%{type: :merchant})

      merchant =
        merchant_fixture(%{user: user, name: "Old Name", description: "Old Description Text"})

      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      view
      |> form("#merchant-form", merchant: %{description: "New Description Here"})
      |> render_submit()

      assert_redirect(view, ~p"/merchants/#{merchant}")

      updated = Trays.Merchants.get_merchant!(merchant.id, user.id)
      assert updated.name == "Old Name"
      assert updated.description == "New Description Here"
    end

    test "form remains on page with errors after save attempt", %{conn: conn} do
      user = user_fixture(%{type: :merchant})
      merchant = merchant_fixture(%{user: user})
      conn = log_in_user(conn, user)

      {:ok, view, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        view
        |> form("#merchant-form", merchant: %{name: ""})
        |> render_submit()

      # Should still be on edit page with error
      assert html =~ "Edit Business"
      assert html =~ "can&#39;t be blank"
      refute_redirected(view)
    end
  end

end
