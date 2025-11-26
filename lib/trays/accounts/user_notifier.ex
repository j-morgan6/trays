defmodule Trays.Accounts.UserNotifier do
  import Swoosh.Email

  alias Trays.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Trays", "no-reply@trays.com"})
      |> subject(subject)
      |> html_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """
    <div>
    Hi #{user.name},

    <p>
    You are receiving this email because you requested to change the
    email associated with your account at Trays. Click <a href="#{url}">here</a>
    to continue with this change.
    </p>

    <p>
    If this change was not requested by you, please ignore this email.
    </p>

    Regards,<br/>
    Team at Trays
    </div>
    """)
  end
end
