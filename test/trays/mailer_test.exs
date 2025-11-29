defmodule Trays.MailerTest do
  use ExUnit.Case, async: true

  alias Trays.Mailer

  describe "configuration" do
    test "mailer module exists and is configured" do
      # Verify the Mailer module exists
      assert Code.ensure_loaded?(Trays.Mailer)
    end

    test "SMTP adapter is available" do
      # Verify the SMTP adapter from Swoosh is available
      assert Code.ensure_loaded?(Swoosh.Adapters.SMTP),
             "Swoosh.Adapters.SMTP module not found"
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
