defmodule TraysWeb.UserLive.Settings do
  use TraysWeb, :live_view

  on_mount {TraysWeb.UserAuth, :require_sudo_mode}

  alias Trays.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[calc(100vh-4rem)] bg-white py-12 px-4 sm:px-6 lg:px-8">
        <div class="max-w-3xl mx-auto">
          <div class="text-center mb-8">
            <h1 class="text-4xl font-bold text-base-content mb-3">{gettext("Account Settings")}</h1>
            <p class="text-base-content/70 text-lg">
              {gettext("Manage your account profile, email address and password settings")}
            </p>
          </div>

          <div class="space-y-6">
            <!-- Profile Section -->
            <div class="bg-white shadow-lg rounded-xl p-6 border-2 border-[#85b4cf]/20">
              <h2 class="text-2xl font-bold text-base-content mb-1">
                {gettext("Profile Information")}
              </h2>
              <p class="text-base-content/70 text-sm mb-6">
                {gettext("Update your name and phone number")}
              </p>

              <.form
                for={@profile_form}
                id="profile_form"
                phx-submit="update_profile"
                phx-change="validate_profile"
                class="space-y-4"
              >
                <.input
                  field={@profile_form[:name]}
                  type="text"
                  label={gettext("Name")}
                  autocomplete="name"
                  required
                />
                <.input
                  field={@profile_form[:phone_number]}
                  type="tel"
                  label={gettext("Phone Number")}
                  autocomplete="tel"
                  required
                />
                <.button
                  class="w-full px-6 py-3 bg-[#85b4cf] text-white font-semibold rounded-lg hover:bg-[#6a94ab] hover:shadow-lg transition-all duration-200"
                  phx-disable-with={gettext("Saving...")}
                >
                  {gettext("Update Profile")}
                </.button>
              </.form>
            </div>
            
    <!-- Email Section -->
            <div class="bg-white shadow-lg rounded-xl p-6 border-2 border-[#85b4cf]/20">
              <h2 class="text-2xl font-bold text-base-content mb-1">{gettext("Email Address")}</h2>
              <p class="text-base-content/70 text-sm mb-6">
                {gettext("Change your email address (requires confirmation)")}
              </p>

              <.form
                for={@email_form}
                id="email_form"
                phx-submit="update_email"
                phx-change="validate_email"
                class="space-y-4"
              >
                <.input
                  field={@email_form[:email]}
                  type="email"
                  label={gettext("Email")}
                  autocomplete="username"
                  required
                />
                <.button
                  class="w-full px-6 py-3 bg-[#85b4cf] text-white font-semibold rounded-lg hover:bg-[#6a94ab] hover:shadow-lg transition-all duration-200"
                  phx-disable-with={gettext("Changing...")}
                >
                  {gettext("Change Email")}
                </.button>
              </.form>
            </div>
            
    <!-- Password Section -->
            <div class="bg-white shadow-lg rounded-xl p-6 border-2 border-[#85b4cf]/20">
              <h2 class="text-2xl font-bold text-base-content mb-1">{gettext("Password")}</h2>
              <p class="text-base-content/70 text-sm mb-6">
                {gettext("Update your password to keep your account secure")}
              </p>

              <.form
                for={@password_form}
                id="password_form"
                action={~p"/users/update-password"}
                method="post"
                phx-change="validate_password"
                phx-submit="update_password"
                phx-trigger-action={@trigger_submit}
                class="space-y-4"
              >
                <input
                  name={@password_form[:email].name}
                  type="hidden"
                  id="hidden_user_email"
                  autocomplete="username"
                  value={@current_email}
                />
                <.input
                  field={@password_form[:password]}
                  type="password"
                  label={gettext("New password")}
                  autocomplete="new-password"
                  required
                />
                <.input
                  field={@password_form[:password_confirmation]}
                  type="password"
                  label={gettext("Confirm new password")}
                  autocomplete="new-password"
                />
                <.button
                  class="w-full px-6 py-3 bg-[#e88e19] text-white font-semibold rounded-lg hover:bg-[#d17d15] hover:shadow-lg transition-all duration-200"
                  phx-disable-with={gettext("Saving...")}
                >
                  {gettext("Save Password")}
                </.button>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_scope.user, token) do
        {:ok, _user} ->
          put_flash(socket, :info, gettext("Email changed successfully."))

        {:error, _} ->
          put_flash(socket, :error, gettext("Email change link is invalid or it has expired."))
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_scope.user
    profile_changeset = Accounts.change_user_profile(user)
    email_changeset = Accounts.change_user_email(user, %{}, validate_unique: false)
    password_changeset = Accounts.change_user_password(user, %{}, hash_password: false)

    socket =
      socket
      |> assign(:current_email, user.email)
      |> assign(:profile_form, to_form(profile_changeset))
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:trigger_submit, false)

    {:ok, socket}
  end

  @impl true
  def handle_event("validate_profile", params, socket) do
    %{"user" => user_params} = params

    profile_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_profile(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, profile_form: profile_form)}
  end

  def handle_event("update_profile", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.update_user_profile(user, user_params) do
      {:ok, _user} ->
        info = gettext("Profile updated successfully.")
        {:noreply, socket |> put_flash(:info, info)}

      {:error, changeset} ->
        {:noreply, assign(socket, :profile_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_email", params, socket) do
    %{"user" => user_params} = params

    email_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_email(user_params, validate_unique: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form)}
  end

  def handle_event("update_email", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_email(user, user_params) do
      %{valid?: true} = changeset ->
        Ecto.Changeset.apply_action!(changeset, :insert)
        |> Accounts.deliver_user_update_email_instructions(
          user.email,
          &url(~p"/users/settings/confirm-email/#{&1}")
        )

        info = gettext("A link to confirm your email change has been sent to the new address.")
        {:noreply, socket |> put_flash(:info, info)}

      changeset ->
        {:noreply, assign(socket, :email_form, to_form(changeset, action: :insert))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"user" => user_params} = params

    password_form =
      socket.assigns.current_scope.user
      |> Accounts.change_user_password(user_params, hash_password: false)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form)}
  end

  def handle_event("update_password", params, socket) do
    %{"user" => user_params} = params
    user = socket.assigns.current_scope.user
    true = Accounts.sudo_mode?(user)

    case Accounts.change_user_password(user, user_params) do
      %{valid?: true} = changeset ->
        {:noreply, assign(socket, trigger_submit: true, password_form: to_form(changeset))}

      changeset ->
        {:noreply, assign(socket, password_form: to_form(changeset, action: :insert))}
    end
  end
end
