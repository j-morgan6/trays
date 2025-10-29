defmodule TraysWeb.Router do
  use TraysWeb, :router

  import TraysWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TraysWeb.Layouts, :root}
    plug :protect_from_forgery

    plug :put_secure_browser_headers, %{
      "content-security-policy" =>
        "default-src 'self'; img-src 'self' data:; style-src 'self' 'unsafe-inline'"
    }

    plug :fetch_current_scope_for_user
    plug TraysWeb.Plugs.Locale, "en"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", TraysWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  # Other scopes may use custom stacks.
  # scope "/api", TraysWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:trays, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:browser, :require_authenticated_user, :require_admin]

      live_dashboard "/dashboard", metrics: TraysWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  scope path: "/feature-flags" do
    pipe_through [:browser, :require_authenticated_user, :require_admin]
    forward "/", FunWithFlags.UI.Router, namespace: "feature-flags"
  end

  ## Authentication routes

  scope "/", TraysWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :require_authenticated_user,
      on_mount: [{TraysWeb.UserAuth, :require_authenticated}] do
      live "/users/settings", UserLive.Settings, :edit
      live "/users/settings/confirm-email/:token", UserLive.Settings, :confirm_email
    end

    post "/users/update-password", UserSessionController, :update_password
  end

  scope "/", TraysWeb do
    pipe_through [:browser]

    live_session :current_user,
      on_mount: [{TraysWeb.UserAuth, :mount_current_scope}] do
      live "/users/register", UserLive.Registration, :new
      live "/users/log-in", UserLive.Login, :new
      live "/users/log-in/:token", UserLive.Confirmation, :new
    end

    post "/users/log-in", UserSessionController, :create
    delete "/users/log-out", UserSessionController, :delete
  end

  ## Store Manager routes

  scope "/", TraysWeb do
    pipe_through [:browser, :require_authenticated_user, :require_store_manager]

    live_session :require_store_manager,
      on_mount: [{TraysWeb.UserAuth, :require_authenticated}] do

        live "/merchant_locations", MerchantLocationLive.Index, :index
      end
  end

  ## Merchant routes

  scope "/", TraysWeb do
    pipe_through [:browser, :require_authenticated_user, :require_merchant]

    live_session :require_merchant,
      on_mount: [{TraysWeb.UserAuth, :require_authenticated}] do
      live "/merchants/:id", MerchantLive.Show, :show
      live "/merchants/:id/edit", MerchantLive.Form, :edit

      live "/merchant_locations/new", MerchantLocationLive.Form, :new
      live "/merchant_locations/:id", MerchantLocationLive.Show, :show
      live "/merchant_locations/:id/edit", MerchantLocationLive.Form, :edit

      live "/merchant_locations/:merchant_location_id/invoices/new", InvoiceLive.Form, :new

      live "/merchant_locations/:merchant_location_id/invoices/:id",
           InvoiceLive.Show,
           :show

      live "/merchant_locations/:merchant_location_id/invoices/:id/edit",
           InvoiceLive.Form,
           :edit

      live "/merchant_locations/:merchant_location_id/bank_accounts/new",
           BankAccountLive.Form,
           :new

      live "/bank_accounts/:id/edit", BankAccountLive.Form, :edit
    end
  end

  # Admin routes

  scope "/", TraysWeb do
    pipe_through [:browser, :require_authenticated_user, :require_admin]

    live_session :require_admin,
      on_mount: [{TraysWeb.UserAuth, :require_authenticated}] do
      live "/merchants", MerchantLive.Index, :index
    end
  end
end
