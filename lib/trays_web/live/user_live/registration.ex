defmodule TraysWeb.UserLive.Registration do
  use TraysWeb, :live_view

  alias Trays.Accounts
  alias Trays.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center bg-base-100 py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md">
          <div class="text-center space-y-3 mb-8">
            <h2 class="text-3xl font-bold text-base-content">
              Create your account
            </h2>
            <p class="text-secondary">
              Already registered?
              <.link
                navigate={~p"/users/log-in"}
                class="font-semibold text-primary hover:text-primary/80 transition-colors"
              >
                Sign in
              </.link>
              to your account.
            </p>
          </div>

          <div class="bg-base-200 shadow-lg rounded-lg p-8 border border-base-300">
            <.form
              for={@form}
              id="registration_form"
              phx-submit="save"
              phx-change="validate"
              class="space-y-5"
            >
              <.input
                field={@form[:email]}
                type="email"
                label="Email"
                placeholder="you@example.com"
                autocomplete="username"
                required
                phx-mounted={JS.focus()}
              />

              <.input
                field={@form[:name]}
                type="text"
                label="Full Name"
                placeholder="John Doe"
                autocomplete="name"
                required
              />

              <.input
                field={@form[:phone_number]}
                type="tel"
                label="Phone Number"
                placeholder="+1 (555) 000-0000"
                autocomplete="tel"
                required
              />

              <.input
                field={@form[:type]}
                type="select"
                label="Account Type"
                options={[{"Customer", :customer}, {"Merchant", :merchant}, {"Admin", :admin}]}
                prompt="Select account type"
                required
              />

              <div class="pt-2">
                <.button
                  phx-disable-with="Creating account..."
                  class="btn btn-accent w-full"
                >
                  Create account
                  <.icon name="hero-arrow-right" class="size-4" />
                </.button>
              </div>

              <p class="text-xs text-center text-secondary pt-2">
                By creating an account, you agree to our Terms of Service and Privacy Policy.
              </p>
            </.form>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, %{assigns: %{current_scope: %{user: user}}} = socket)
      when not is_nil(user) do
    {:ok, redirect(socket, to: TraysWeb.UserAuth.signed_in_path(socket))}
  end

  def mount(_params, _session, socket) do
    changeset = User.registration_changeset(%User{}, %{}, validate_unique: false)

    {:ok, assign_form(socket, changeset), temporary_assigns: [form: nil]}
  end

  @impl true
  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_login_instructions(
            user,
            &url(~p"/users/log-in/#{&1}")
          )

        {:noreply,
         socket
         |> put_flash(
           :info,
           "An email was sent to #{user.email}, please access it to confirm your account."
         )
         |> push_navigate(to: ~p"/users/log-in")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset =
      User.registration_changeset(%User{}, user_params,
        validate_unique: false,
        hash_password: false
      )

    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    assign(socket, form: form)
  end
end
