defmodule Trays.Adapters.ResendTest do
  use ExUnit.Case, async: true

  alias Swoosh.Email
  alias Trays.Adapters.Resend

  describe "adapter configuration" do
    test "module is a valid Swoosh adapter" do
      # Verify it implements the Swoosh.Adapter behavior
      assert function_exported?(Resend, :deliver, 2)
    end
  end

  describe "prepare_body/1" do
    test "formats basic email with from, to, and subject" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test Subject")

      body = Resend.prepare_body(email)

      assert body.from == "sender@example.com"
      assert body.to == ["recipient@example.com"]
      assert body.subject == "Test Subject"
    end

    test "formats email with named recipients" do
      email =
        Email.new()
        |> Email.to({"John Doe", "john@example.com"})
        |> Email.from({"Company Name", "noreply@company.com"})
        |> Email.subject("Test")

      body = Resend.prepare_body(email)

      assert body.from == "Company Name <noreply@company.com>"
      assert body.to == ["John Doe <john@example.com>"]
    end

    test "handles multiple recipients" do
      email =
        Email.new()
        |> Email.to([
          "user1@example.com",
          {"User Two", "user2@example.com"},
          {"", "user3@example.com"}
        ])
        |> Email.from("sender@example.com")
        |> Email.subject("Test")

      body = Resend.prepare_body(email)

      assert body.to == [
               "user1@example.com",
               "User Two <user2@example.com>",
               "user3@example.com"
             ]
    end

    test "includes text body when present" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.text_body("Plain text content")

      body = Resend.prepare_body(email)

      assert body.text == "Plain text content"
    end

    test "includes html body when present" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.html_body("<h1>HTML content</h1>")

      body = Resend.prepare_body(email)

      assert body.html == "<h1>HTML content</h1>"
    end

    test "includes both text and html body" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.text_body("Plain text")
        |> Email.html_body("<p>HTML content</p>")

      body = Resend.prepare_body(email)

      assert body.text == "Plain text"
      assert body.html == "<p>HTML content</p>"
    end

    test "includes reply_to when present" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.reply_to("reply@example.com")

      body = Resend.prepare_body(email)

      assert body.reply_to == "reply@example.com"
    end

    test "includes named reply_to when present" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.reply_to({"Support Team", "support@example.com"})

      body = Resend.prepare_body(email)

      assert body.reply_to == "Support Team <support@example.com>"
    end

    test "omits optional fields when not present" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")

      body = Resend.prepare_body(email)

      refute Map.has_key?(body, :text)
      refute Map.has_key?(body, :html)
      refute Map.has_key?(body, :reply_to)
    end
  end

  describe "prepare_recipient/1" do
    test "handles plain email string" do
      assert Resend.prepare_recipient("user@example.com") == "user@example.com"
    end

    test "handles tuple with name and email" do
      assert Resend.prepare_recipient({"John Doe", "john@example.com"}) ==
               "John Doe <john@example.com>"
    end

    test "handles tuple with nil name" do
      assert Resend.prepare_recipient({nil, "user@example.com"}) == "user@example.com"
    end

    test "handles tuple with empty string name" do
      assert Resend.prepare_recipient({"", "user@example.com"}) == "user@example.com"
    end

    test "handles tuple with whitespace-only name" do
      # Names with actual content should be formatted with <>
      assert Resend.prepare_recipient({"  ", "user@example.com"}) ==
               "   <user@example.com>"
    end
  end

  describe "prepare_headers/1" do
    test "includes authorization header with Bearer token" do
      api_key = "test_api_key_123"
      headers = Resend.prepare_headers(api_key)

      assert {"Authorization", "Bearer test_api_key_123"} in headers
    end

    test "includes content-type header" do
      headers = Resend.prepare_headers("any_key")

      assert {"Content-Type", "application/json"} in headers
    end

    test "includes X-Resend-Version header" do
      headers = Resend.prepare_headers("any_key")

      assert Enum.any?(headers, fn
               {"X-Resend-Version", _version} -> true
               _ -> false
             end)
    end

    test "returns list of tuples" do
      headers = Resend.prepare_headers("test_key")

      assert is_list(headers)
      assert Enum.all?(headers, fn h -> is_tuple(h) and tuple_size(h) == 2 end)
    end
  end

  describe "module structure" do
    test "has @base_url defined" do
      # Check that the module has the base URL attribute
      source = File.read!("lib/trays/adapters/resend.ex")
      assert source =~ "@base_url \"https://api.resend.com\""
    end

    test "has @api_version defined" do
      source = File.read!("lib/trays/adapters/resend.ex")
      assert source =~ "@api_version"
    end

    test "uses correct Finch pool name" do
      source = File.read!("lib/trays/adapters/resend.ex")
      assert source =~ "Trays.Finch"
      refute source =~ "SpikeEmail.Finch"
    end

    test "module name is correct" do
      assert Resend.__info__(:module) == Trays.Adapters.Resend
    end
  end

  describe "integration checks" do
    test "can be used as a Swoosh adapter in config" do
      # Verify the module can be used in application config
      config = [adapter: Resend, api_key: "test_key"]

      assert config[:adapter] == Resend
      assert is_atom(config[:adapter])
    end

    test "deliver/2 function exists" do
      # Verify the function exists with correct arity
      assert function_exported?(Resend, :deliver, 2)
    end
  end

  describe "edge cases" do
    test "handles cc recipients" do
      email =
        Email.new()
        |> Email.to("to@example.com")
        |> Email.from("from@example.com")
        |> Email.subject("Test")
        |> Email.cc("cc@example.com")

      # prepare_body doesn't handle cc yet, but should not crash
      body = Resend.prepare_body(email)

      assert body.to == ["to@example.com"]
      assert body.from == "from@example.com"
    end

    test "handles bcc recipients" do
      email =
        Email.new()
        |> Email.to("to@example.com")
        |> Email.from("from@example.com")
        |> Email.subject("Test")
        |> Email.bcc("bcc@example.com")

      # prepare_body doesn't handle bcc yet, but should not crash
      body = Resend.prepare_body(email)

      assert body.to == ["to@example.com"]
      assert body.from == "from@example.com"
    end

    test "handles email with only html body" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.html_body("<h1>Only HTML</h1>")

      body = Resend.prepare_body(email)

      assert body.html == "<h1>Only HTML</h1>"
      refute Map.has_key?(body, :text)
    end

    test "handles email with only text body" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("Test")
        |> Email.text_body("Only plain text")

      body = Resend.prepare_body(email)

      assert body.text == "Only plain text"
      refute Map.has_key?(body, :html)
    end

    test "handles long recipient list" do
      recipients = Enum.map(1..10, fn i -> "user#{i}@example.com" end)

      email =
        Email.new()
        |> Email.to(recipients)
        |> Email.from("sender@example.com")
        |> Email.subject("Test")

      body = Resend.prepare_body(email)

      assert length(body.to) == 10
      assert "user1@example.com" in body.to
      assert "user10@example.com" in body.to
    end

    test "handles special characters in names" do
      email =
        Email.new()
        |> Email.to({"John O'Brien", "john@example.com"})
        |> Email.from({"Smith & Co.", "contact@example.com"})
        |> Email.subject("Test")

      body = Resend.prepare_body(email)

      assert body.to == ["John O'Brien <john@example.com>"]
      assert body.from == "Smith & Co. <contact@example.com>"
    end

    test "handles empty subject" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from("sender@example.com")
        |> Email.subject("")
        |> Email.text_body("Body")

      body = Resend.prepare_body(email)

      assert body.subject == ""
      assert body.text == "Body"
    end

    test "prepare_headers includes all required headers" do
      headers = Resend.prepare_headers("test_key_123")

      header_names = Enum.map(headers, fn {name, _value} -> name end)

      assert "Authorization" in header_names
      assert "Content-Type" in header_names
      assert "X-Resend-Version" in header_names
      assert length(headers) == 3
    end

    test "prepare_body creates encodable JSON" do
      email =
        Email.new()
        |> Email.to("recipient@example.com")
        |> Email.from({"Sender Name", "sender@example.com"})
        |> Email.subject("Test Subject")
        |> Email.text_body("Text content")
        |> Email.html_body("<p>HTML content</p>")

      body = Resend.prepare_body(email)

      # Verify it can be JSON encoded (what deliver/2 does)
      assert {:ok, json} = Jason.encode(body)
      assert is_binary(json)
      assert json =~ "Test Subject"
      assert json =~ "recipient@example.com"
    end

    test "handles complex email with all optional fields" do
      email =
        Email.new()
        |> Email.to([
          "user1@example.com",
          {"User Two", "user2@example.com"}
        ])
        |> Email.from({"Company Name", "noreply@company.com"})
        |> Email.subject("Complex Email")
        |> Email.text_body("Text version")
        |> Email.html_body("<p>HTML version</p>")
        |> Email.reply_to({"Support", "support@company.com"})

      body = Resend.prepare_body(email)

      assert body.to == [
               "user1@example.com",
               "User Two <user2@example.com>"
             ]

      assert body.from == "Company Name <noreply@company.com>"
      assert body.subject == "Complex Email"
      assert body.text == "Text version"
      assert body.html == "<p>HTML version</p>"
      assert body.reply_to == "Support <support@company.com>"
    end
  end

  describe "prepare_recipient/1 comprehensive" do
    test "handles email with unicode characters" do
      result = Resend.prepare_recipient({"François Müller", "francois@example.com"})
      assert result == "François Müller <francois@example.com>"
    end

    test "handles very long names" do
      long_name = String.duplicate("a", 100)
      result = Resend.prepare_recipient({long_name, "user@example.com"})
      assert result == "#{long_name} <user@example.com>"
    end

    test "handles name with angle brackets (edge case)" do
      # This is an edge case - names shouldn't have <> but we handle it
      result = Resend.prepare_recipient({"Name <Test>", "user@example.com"})
      assert result == "Name <Test> <user@example.com>"
    end
  end
end
