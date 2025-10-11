defmodule TraysWeb.UserLive.Registration do
  use TraysWeb, :live_view

  alias Trays.Accounts
  alias Trays.Accounts.User

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center bg-white py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md">
          <div class="text-center space-y-3 mb-8">
            <h2 class="text-3xl font-bold text-base-content">
              {gettext("Create your account")}
            </h2>
            <p class="text-base-content/70">
              {gettext("Already registered?")}
              <.link
                navigate={~p"/users/log-in"}
                class="font-semibold text-[#85b4cf] hover:text-[#6a94ab] transition-colors"
              >
                {gettext("Sign in")}
              </.link>
              {gettext("to your account.")}
            </p>
          </div>

          <div class="bg-white shadow-2xl rounded-xl p-8 border-2 border-[#85b4cf]/20">
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
                label={gettext("Email")}
                placeholder="you@example.com"
                autocomplete="username"
                required
                phx-mounted={JS.focus()}
              />

              <.input
                field={@form[:name]}
                type="text"
                label={gettext("Full Name")}
                placeholder="John Doe"
                autocomplete="name"
                required
              />

              <.input
                field={@form[:phone_number]}
                type="tel"
                label={gettext("Phone Number")}
                placeholder="+1 (555) 000-0000"
                autocomplete="tel"
                required
              />

              <.input
                field={@form[:type]}
                type="select"
                label={gettext("Account Type")}
                options={[
                  {gettext("Customer"), :customer},
                  {gettext("Store Manager"), :store_manager},
                  {gettext("Merchant"), :merchant}
                ]}
                prompt={gettext("Select account type")}
                required
              />

              <div class="pt-2">
                <.button
                  phx-disable-with={gettext("Creating account...")}
                  class="w-full px-6 py-3 bg-[#e88e19] text-white font-semibold rounded-lg hover:bg-[#d17d15] hover:shadow-lg transition-all duration-200"
                >
                  {gettext("Create account")} <.icon name="hero-arrow-right" class="size-4 inline" />
                </.button>
              </div>

              <p class="text-xs text-center text-base-content pt-2">
                {gettext(
                  "By creating an account, you agree to our Terms of Service and Privacy Policy."
                )}
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
    {:ok, redirect(socket, to: TraysWeb.UserAuth.signed_in_path(user, true))}
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
           gettext("An email was sent to %{email}, please access it to confirm your account.",
             email: user.email
           )
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
