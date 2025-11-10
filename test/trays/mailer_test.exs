defmodule Trays.MailerTest do
  use ExUnit.Case, async: true

  alias Trays.Mailer

  describe "configuration" do
    test "mailer module exists and is configured" do
      # Verify the Mailer module exists
      assert Code.ensure_loaded?(Trays.Mailer)
    end

    test "adapter module exists in production config" do
      # In test, it might be Swoosh.Adapters.Test, but we want to verify
      # the production adapter (Trays.Adapters.Resend) compiles
      assert Code.ensure_loaded?(Trays.Adapters.Resend),
             "Trays.Adapters.Resend module not found - check module name in lib/trays/adapters/resend.ex"
    end

    test "Finch pool is configured correctly" do
      # Verify Trays.Finch is the correct pool name used in the adapter
      assert Code.ensure_loaded?(Finch)

      # This ensures at compile time that if we typo the Finch pool name,
      # it will be caught
      adapter_source = File.read!("lib/trays/adapters/resend.ex")

      assert adapter_source =~ "Trays.Finch",
             "Adapter should use Trays.Finch, not SpikeEmail.Finch or other incorrect pool name"

      refute adapter_source =~ "SpikeEmail.Finch",
             "Found reference to SpikeEmail.Finch - should be Trays.Finch"
    end

    test "adapter module name matches config" do
      # Read the adapter source and verify module name
      adapter_source = File.read!("lib/trays/adapters/resend.ex")

      assert adapter_source =~ "defmodule Trays.Adapters.Resend do",
             "Adapter module should be named Trays.Adapters.Resend"

      refute adapter_source =~ "SpikeEmail.Adapters",
             "Found SpikeEmail namespace - should be Trays namespace"
    end
  end

  describe "email sending in test environment" do
    import Swoosh.Email

    test "can deliver test email" do
      email =
        new()
        |> to("test@example.com")
        |> from({"Test", "noreply@example.com"})
        |> subject("Test Email")
        |> text_body("This is a test")

      # In test env, this uses Swoosh.Adapters.Test
      assert {:ok, _} = Mailer.deliver(email)
    end
  end
end
