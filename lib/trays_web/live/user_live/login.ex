defmodule TraysWeb.UserLive.Login do
  use TraysWeb, :live_view

  alias Trays.Accounts

  @impl true
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="min-h-[calc(100vh-4rem)] flex items-center justify-center bg-base-100 py-12 px-4 sm:px-6 lg:px-8">
        <div class="w-full max-w-md">
          <div class="text-center space-y-3 mb-8">
            <h2 class="text-3xl font-bold text-base-content">
              Welcome back
            </h2>
            <p class="text-secondary">
              <%= if @current_scope do %>
                You need to reauthenticate to perform sensitive actions on your account.
              <% else %>
                Don't have an account? <.link
                  navigate={~p"/users/register"}
                  class="font-semibold text-primary hover:text-primary/80 transition-colors"
                  phx-no-format
                >Sign up</.link>
              <% end %>
            </p>
          </div>

          <div class="bg-base-200 shadow-lg rounded-lg p-8 border border-base-300 space-y-6">
            <div
              :if={local_mail_adapter?()}
              class="alert bg-info/20 border border-info/30"
            >
              <.icon name="hero-information-circle" class="size-5 shrink-0 text-info" />
              <div class="text-sm text-base-content">
                <p class="font-medium">Development Mode</p>
                <p class="text-secondary">
                  View emails at <.link
                    href="/dev/mailbox"
                    class="underline hover:no-underline text-primary"
                  >the mailbox page</.link>.
                </p>
              </div>
            </div>

            <div class="space-y-4">
              <h3 class="text-lg font-semibold text-base-content">Magic Link Login</h3>
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
                  label="Email"
                  placeholder="you@example.com"
                  autocomplete="username"
                  required
                  phx-mounted={JS.focus()}
                />
                <.button class="btn btn-primary w-full">
                  Send magic link <.icon name="hero-paper-airplane" class="size-4" />
                </.button>
              </.form>
            </div>

            <div class="divider text-sm text-secondary">or continue with password</div>

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
                  label="Email"
                  placeholder="you@example.com"
                  autocomplete="username"
                  required
                />
                <.input
                  field={@form[:password]}
                  type="password"
                  label="Password"
                  placeholder="••••••••"
                  autocomplete="current-password"
                />
                <div class="space-y-3">
                  <.button
                    class="btn btn-accent w-full"
                    name={@form[:remember_me].name}
                    value="true"
                  >
                    Sign in and stay signed in <.icon name="hero-arrow-right" class="size-4" />
                  </.button>
                  <.button class="btn btn-ghost w-full border border-base-content/20 text-base-content">
                    Sign in for this session only
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
      "If your email is in our system, you will receive instructions for logging in shortly."

    {:noreply,
     socket
     |> put_flash(:info, info)
     |> push_navigate(to: ~p"/users/log-in")}
  end

  defp local_mail_adapter? do
    Application.get_env(:trays, Trays.Mailer)[:adapter] == Swoosh.Adapters.Local
  end
end
