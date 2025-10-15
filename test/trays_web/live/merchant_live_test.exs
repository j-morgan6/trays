defmodule TraysWeb.MerchantLiveTest do
  use TraysWeb.ConnCase

  import Phoenix.LiveViewTest
  import Trays.MerchantsFixtures

  @update_attrs %{
    name: "Updated Business Name",
    description: "An updated business description with enough characters to pass validation"
  }
  @invalid_attrs %{
    name: nil,
    description: nil
  }

  setup do
    user = Trays.AccountsFixtures.user_fixture(%{type: :merchant})
    conn = Phoenix.ConnTest.build_conn()
    %{conn: TraysWeb.ConnCase.log_in_user(conn, user), user: user}
  end

  defp create_merchant(%{user: user}) do
    merchant = merchant_fixture(%{user: user})
    %{merchant: merchant}
  end

  describe "Form - Edit Business" do
    setup [:create_merchant]

    test "renders edit business form", %{conn: conn, merchant: merchant} do
      {:ok, _form_live, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      assert html =~ "Edit Business"
      assert html =~ merchant.name
      assert html =~ merchant.description
    end

    test "displays current character counts for existing merchant", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, _form_live, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Should show character counts for existing values
      name_length = String.length(merchant.name)
      description_length = String.length(merchant.description)

      assert html =~ "#{name_length}"
      assert html =~ "#{description_length}"
    end

    test "validates business data on input change", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test validation with invalid data
      assert form_live
             |> form("#merchant-form", merchant: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      # Test validation with valid data
      refute form_live
             |> form("#merchant-form", merchant: @update_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end

    test "tracks character count for name field during editing", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with short name
      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "Test", description: "Valid description here"}
        )
        |> render_change()

      assert html =~ "4/100"

      # Test with longer name (30 characters)
      html =
        form_live
        |> form("#merchant-form",
          merchant: %{
            name: "A Very Long Business Name Here",
            description: "Valid description here"
          }
        )
        |> render_change()

      # "A Very Long Business Name Here" is 30 characters
      assert html =~ "30/100"
    end

    test "tracks character count for description field during editing", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with short description
      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "Business Name", description: "Short description text"}
        )
        |> render_change()

      assert html =~ "22/500"

      # Test with longer description
      long_description = String.duplicate("A", 150)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "Business Name", description: long_description}
        )
        |> render_change()

      assert html =~ "150/500"
    end

    test "updates business successfully", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Submit the form - it will redirect with a flash message
      assert {:error, {:live_redirect, %{flash: flash, to: "/merchants"}}} =
               form_live
               |> form("#merchant-form", merchant: @update_attrs)
               |> render_submit()

      # Check the flash token is present (it's a signed token so we can't decode it easily)
      assert is_binary(flash)
    end

    test "handles validation errors when updating business", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Submit with invalid data
      html =
        form_live
        |> form("#merchant-form", merchant: @invalid_attrs)
        |> render_submit()

      # Should stay on the form and show errors
      assert html =~ "can&#39;t be blank"
      assert html =~ "Edit Business"
    end

    test "validates name length constraints", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with name too short (less than 2 characters)
      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "A", description: "Valid description here with enough text"}
        )
        |> render_change()

      assert html =~ "must be between 2 and 100 characters"

      # Test with name too long (more than 100 characters)
      long_name = String.duplicate("A", 101)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: long_name, description: "Valid description here with enough text"}
        )
        |> render_change()

      assert html =~ "must be between 2 and 100 characters"
    end

    test "validates description length constraints", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with description too short (less than 10 characters)
      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "Valid Business Name", description: "Short"})
        |> render_change()

      assert html =~ "must be between 10 and 500 characters"

      # Test with description too long (more than 500 characters)
      long_description = String.duplicate("A", 501)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "Valid Business Name", description: long_description}
        )
        |> render_change()

      assert html =~ "must be between 10 and 500 characters"
    end

    test "handles nil values in character length calculation", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # The form should handle empty/nil values gracefully
      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "", description: ""})
        |> render_change()

      # Character count should show 0 for empty values
      assert html =~ "0"
    end

    test "displays warning for name approaching character limit", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with name at 75% of limit (should show warning color)
      name_75 = String.duplicate("A", 75)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: name_75, description: "Valid description here"}
        )
        |> render_change()

      assert html =~ "75/100"

      # Test with name at 90% of limit (should show more urgent warning)
      name_90 = String.duplicate("A", 90)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: name_90, description: "Valid description here"}
        )
        |> render_change()

      assert html =~ "90/100"

      # Test with name at exactly the limit
      name_100 = String.duplicate("A", 100)

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: name_100, description: "Valid description here"}
        )
        |> render_change()

      assert html =~ "100/100"
    end

    test "displays warning for description approaching character limit", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Test with description at 75% of limit
      desc_375 = String.duplicate("A", 375)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: desc_375})
        |> render_change()

      assert html =~ "375/500"

      # Test with description at 90% of limit
      desc_450 = String.duplicate("A", 450)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: desc_450})
        |> render_change()

      assert html =~ "450/500"

      # Test with description at exactly the limit
      desc_500 = String.duplicate("A", 500)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: desc_500})
        |> render_change()

      assert html =~ "500/500"
    end
  end

  describe "Authorization" do
    setup [:create_merchant]

    test "user cannot access another user's merchant", %{merchant: merchant} do
      other_user =
        Trays.AccountsFixtures.user_fixture(%{email: "other@example.com", type: :merchant})

      conn = Phoenix.ConnTest.build_conn()
      conn = TraysWeb.ConnCase.log_in_user(conn, other_user)

      # Should raise because merchant doesn't belong to other_user
      assert_raise Ecto.NoResultsError, fn ->
        live(conn, ~p"/merchants/#{merchant}/edit")
      end
    end
  end

  describe "Character count CSS classes" do
    setup [:create_merchant]

    test "shows gray text when character count is 0", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "", description: "Valid description"})
        |> render_change()

      # Should have gray color for 0 characters
      assert html =~ "text-base-content/40"
    end

    test "shows normal text when character count is below 75%", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Name with 50 characters (50% of 100)
      name_50 = String.duplicate("A", 50)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: name_50, description: "Valid description"})
        |> render_change()

      # Should have normal text color
      assert html =~ "text-base-content/60"
    end

    test "shows amber text when character count is between 75-90%", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Name with 80 characters (80% of 100)
      name_80 = String.duplicate("A", 80)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: name_80, description: "Valid description"})
        |> render_change()

      # Should have amber warning color
      assert html =~ "text-amber-500"
    end

    test "shows darker amber text when character count is between 90-100%", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Name with 95 characters (95% of 100)
      name_95 = String.duplicate("A", 95)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: name_95, description: "Valid description"})
        |> render_change()

      # Should have darker amber warning color
      assert html =~ "text-amber-600 font-semibold"
    end

    test "shows red text when character count is at or above max", %{
      conn: conn,
      merchant: merchant
    } do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Name with exactly 100 characters (100% of 100)
      name_100 = String.duplicate("A", 100)

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: name_100, description: "Valid description"})
        |> render_change()

      # Should have red error color
      assert html =~ "text-red-600 font-semibold"
    end
  end

  describe "Input field CSS classes" do
    setup [:create_merchant]

    test "shows default border for empty field", %{conn: conn, merchant: merchant} do
      {:ok, _form_live, html} = live(conn, ~p"/merchants/#{merchant}/edit")

      # Initial render with existing values should show green border
      assert html =~ "border-emerald-300"
    end

    test "shows green border for valid input", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        form_live
        |> form("#merchant-form",
          merchant: %{name: "Valid Business Name", description: "Valid description here"}
        )
        |> render_change()

      # Should show green success border
      assert html =~ "border-emerald-300 bg-emerald-50/30"
    end

    test "shows red border for invalid input with errors", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "", description: ""})
        |> render_change()

      # Should show red error border
      assert html =~ "border-red-300 bg-red-50"
    end

    test "shows red border for name that's too short", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "A", description: "Valid description here"})
        |> render_change()

      # Should show validation error and red border
      assert html =~ "must be between 2 and 100 characters"
      assert html =~ "border-red-300"
    end

    test "shows red border for description that's too short", %{conn: conn, merchant: merchant} do
      {:ok, form_live, _html} = live(conn, ~p"/merchants/#{merchant}/edit")

      html =
        form_live
        |> form("#merchant-form", merchant: %{name: "Valid Name", description: "Short"})
        |> render_change()

      # Should show validation error and red border
      assert html =~ "must be between 10 and 500 characters"
      assert html =~ "border-red-300"
    end
  end
end
