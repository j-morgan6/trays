defmodule Trays.EmailsTest do
  use ExUnit.Case, async: false

  import Swoosh.TestAssertions

  alias Swoosh.Email
  alias Trays.Emails

  describe "foo_email/0" do
    test "returns a Swoosh.Email struct" do
      email = Emails.foo_email()
      assert %Email{} = email
    end

    test "has correct recipient" do
      email = Emails.foo_email()
      assert email.to == [{"", "foo@example.com"}]
    end

    test "has correct sender" do
      email = Emails.foo_email()
      assert email.from == {"", "bar@example.com"}
    end

    test "has correct subject" do
      email = Emails.foo_email()
      assert email.subject == "Hello"
    end

    test "has text body" do
      email = Emails.foo_email()
      assert email.text_body == "This is a simple email"
    end

    test "does not have html body by default" do
      email = Emails.foo_email()
      assert email.html_body == nil
    end
  end

  describe "email module structure" do
    test "imports Swoosh.Email" do
      # Verify the module compiles and has access to Swoosh.Email functions
      assert function_exported?(Emails, :foo_email, 0)
    end

    test "can be delivered via Trays.Mailer" do
      # Verify emails can be piped to the mailer
      email = Emails.foo_email()

      # In test env, this uses Swoosh.Adapters.Test
      assert {:ok, _metadata} = Trays.Mailer.deliver(email)
    end
  end

  describe "email best practices" do
    test "all email functions should return Email struct" do
      # Test foo_email
      email = Emails.foo_email()
      assert %Email{} = email, "foo_email/0 should return a Swoosh.Email struct"

      # Test invoice_email with valid data
      email =
        Emails.invoice_email(
          "test@example.com",
          "Test Client",
          "INV-001",
          "Dec 31, 2025",
          [%{description: "Test", amount: "$100"}],
          "$100",
          "https://example.com"
        )

      assert %Email{} = email, "invoice_email/7 should return a Swoosh.Email struct"
    end

    test "emails have required fields" do
      email = Emails.foo_email()

      # Every email should have these
      assert email.to != nil, "Email should have a recipient"
      assert email.from != nil, "Email should have a sender"
      assert email.subject != nil, "Email should have a subject"

      # Should have at least one body type
      assert email.text_body != nil || email.html_body != nil,
             "Email should have either text_body or html_body"
    end
  end

  describe "integration with mailer" do
    test "can send email through test adapter" do
      email = Emails.foo_email()

      assert {:ok, _} = Trays.Mailer.deliver(email)

      # Verify it was sent
      assert_email_sent(subject: "Hello")
    end

    test "email is delivered with correct content" do
      email = Emails.foo_email()

      Trays.Mailer.deliver(email)

      # Verify the delivered email has the expected properties
      assert_email_sent(fn sent_email ->
        sent_email.subject == "Hello" &&
          sent_email.text_body == "This is a simple email"
      end)
    end
  end
end
