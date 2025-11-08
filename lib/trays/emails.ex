defmodule Trays.Emails do
  import Swoosh.Email

  # Example of useage, create a private html template and pass it to the email
  # def simple_text_email() do
  #   new()
  #   |> to("foo@example.com")
  #   |> from("bar@example.com")
  #   |> subject("Hello")
  #   |> html_body(foo_html)
  #   |> text_body("This is a simple email")
  # end

  def foo_email do
    new()
    |> to("foo@example.com")
    |> from("bar@example.com")
    |> subject("Hello")
    |> text_body("This is a simple email")
  end
end
