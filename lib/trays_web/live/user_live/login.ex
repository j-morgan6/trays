defmodule TraysWeb.UserLive.Login do
  use TraysWeb, :live_view

  alias Trays.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center bg-white py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md">
          <div class="text-center space-y-3 mb-8">
            <h2 class="text-3xl font-bold text-base-content">
              {gettext("Welcome back")}
            </h2>
            <p class="text-base-content/70">
              <%= if @current_scope do %>
                {gettext("You need to reauthenticate to perform sensitive actions on your account.")}
              <% else %>
                {gettext("Don't have an account?")} <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-[#85b4cf] hover:text-[#6a94ab] transition-colors"
                  phx-no-format
                >{gettext("Sign up")}</.link>
              <% end %>
            </p>
          </div>

          <div class="bg-white shadow-2xl rounded-xl p-8 border-2 border-[#85b4cf]/20 space-y-6">
            <div
              :if={local_mail_adapter?()}
              class="bg-[#85b4cf]/10 border-2 border-[#85b4cf]/30 rounded-lg p-4"
            >
              <.icon
                name="hero-information-circle"
                class="size-5 shrink-0 text-[#85b4cf] inline-block mb-1"
              />
              <div class="text-sm text-base-content inline">
                <p class="font-semibold inline">{gettext("Development Mode")}</p>
                <p class="text-base-content/70 inline">
                  - {gettext("View emails at")} <.link
                    href="/dev/mailbox"
                    class="underline hover:no-underline text-[#85b4cf] font-medium"
                  >{gettext("the mailbox page")}</.link>.
                </p>
              </div>
            </div>

            <div class="space-y-4">
              <h3 class="text-lg font-bold text-base-content">{gettext("Magic Link Login")}</h3>
              <.form
                :let={f}
                for={@form}
                id="login_form_magic"
                action={~p"/users/log-in"}
                phx-submit="submit_magic"
                class="space-y-4"
              >
                <.input
                  readonly={!!@current_scope}
                  field={f[:email]}
                  type="email"
                  label={gettext("Email")}
                  placeholder="you@example.com"
                  autocomplete="username"
                  required
                  phx-mounted={JS.focus()}
                />
                <.button class="w-full px-6 py-3 bg-[#85b4cf] text-white font-semibold rounded-lg hover:bg-[#6a94ab] hover:shadow-lg transition-all duration-200">
                  {gettext("Send magic link")} <.icon name="hero-paper-airplane" class="size-4 inline" />
                </.button>
              </.form>
            </div>

            <div class="relative">
              <div class="absolute inset-0 flex items-center">
                <div class="w-full border-t border-base-content/20"></div>
              </div>
              <div class="relative flex justify-center text-sm">
                <span class="px-4 bg-white text-base-content/60 font-medium">
                  {gettext("or continue with password")}
                </span>
              </div>
            </div>

            <div class="space-y-4">
              <.form
                :let={f}
                for={@form}
                id="login_form_password"
                action={~p"/users/log-in"}
                phx-submit="submit_password"
                phx-trigger-action={@trigger_submit}
                class="space-y-4"
              >
                <.input
                  readonly={!!@current_scope}
                  field={f[:email]}
                  type="email"
                  label={gettext("Email")}
                  placeholder="you@example.com"
                  autocomplete="username"
                  required
                />
                <.input
                  field={@form[:password]}
                  type="password"
                  label={gettext("Password")}
                  placeholder="••••••••"
                  autocomplete="current-password"
                />
                <div class="space-y-3">
                  <.button
                    class="w-full px-6 py-3 bg-[#e88e19] text-white font-semibold rounded-lg hover:bg-[#d17d15] hover:shadow-lg transition-all duration-200"
                    name={@form[:remember_me].name}
                    value="true"
                  >
                    {gettext("Sign in and stay signed in")} <.icon name="hero-arrow-right" class="size-4 inline" />
                  </.button>
                  <.button class="w-full px-6 py-3 bg-white text-base-content font-semibold rounded-lg border-2 border-base-content/30 hover:bg-base-content/5 hover:border-base-content transition-all duration-200">
                    {gettext("Sign in for this session only")}
                  </.button>
                </div>
              </.form>
            </div>
          </div>
        </div>
      </div>
    </Layouts.app>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    email =
      Phoenix.Flash.get(socket.assigns.flash, :email) ||
        get_in(socket.assigns, [:current_scope, Access.key(:user), Access.key(:email)])

    form = to_form(%{"email" => email}, as: "user")

    {:ok, assign(socket, form: form, trigger_submit: false)}
  end

  @impl true
  def handle_event("submit_password", _params, socket) do
    {:noreply, assign(socket, :trigger_submit, true)}
  end

  def handle_event("submit_magic", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_login_instructions(
        user,
        &url(~p"/users/log-in/#{&1}")
      )
    end

    info =
      gettext("If your email is in our system, you will receive instructions for logging in shortly.")

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:trays, Trays.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
