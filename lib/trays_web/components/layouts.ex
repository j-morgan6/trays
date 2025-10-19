defmodule TraysWeb.Layouts do
  @moduledoc """
  This module holds layouts and related functionality
  used by your application.
  """
  use TraysWeb, :html

  embed_templates "layouts/*"

  @doc """
  Renders your app layout.

  This function is typically invoked from every template,
  and it often contains your application menu, sidebar,
  or similar.

  ## Examples

      <Layouts.app flash={@flash}>
        <h1>Content</h1>
      </Layouts.app>

  """
  attr :flash, :map, required: true, doc: "the map of flash messages"

  attr :current_scope, :map,
    default: nil,
    doc: "the current [scope](https://hexdocs.pm/phoenix/scopes.html)"

  slot :inner_block, required: true

  def app(assigns) do
    ~H"""
    <main class="min-h-screen">
      {render_slot(@inner_block)}
    </main>

    <.flash_group flash={@flash} />
    """
  end

  @doc """
  Shows the flash group with standard titles and content.

  ## Examples

      <.flash_group flash={@flash} />
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :id, :string, default: "flash-group", doc: "the optional id of flash container"

  def flash_group(assigns) do
    ~H"""
    <div id={@id} aria-live="polite" class="fixed top-20 right-4 z-50 space-y-2 max-w-md">
      <.flash kind={:info} flash={@flash} />
      <.flash kind={:error} flash={@flash} />

      <.flash
        id="client-error"
        kind={:error}
        title={gettext("We can't find the internet")}
        phx-disconnected={show(".phx-client-error #client-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#client-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>

      <.flash
        id="server-error"
        kind={:error}
        title={gettext("Something went wrong!")}
        phx-disconnected={show(".phx-server-error #server-error") |> JS.remove_attribute("hidden")}
        phx-connected={hide("#server-error") |> JS.set_attribute({"hidden", ""})}
        hidden
      >
        {gettext("Attempting to reconnect")}
        <.icon name="hero-arrow-path" class="ml-1 size-3 motion-safe:animate-spin" />
      </.flash>
    </div>
    """
  end

  @doc """
  Provides dark vs light theme toggle based on themes defined in app.css.

  See <head> in root.html.heex which applies the theme before page load.
  """
  def theme_toggle(assigns) do
    ~H"""
    <div class="relative flex items-center bg-base-200 rounded-full p-1">
      <div class="absolute w-8 h-8 rounded-full bg-primary/20 left-1 [[data-theme=light]_&]:left-[2.25rem] [[data-theme=dark]_&]:left-[3.75rem] transition-all duration-200 ease-in-out" />

      <button
        class="relative flex items-center justify-center w-8 h-8 cursor-pointer rounded-full hover:bg-base-300/50 transition-colors z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="system"
        title="System theme"
      >
        <.icon name="hero-computer-desktop-micro" class="size-4 [[data-theme=system]_&]:text-primary" />
      </button>

      <button
        class="relative flex items-center justify-center w-8 h-8 cursor-pointer rounded-full hover:bg-base-300/50 transition-colors z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="light"
        title="Light theme"
      >
        <.icon name="hero-sun-micro" class="size-4 [[data-theme=light]_&]:text-primary" />
      </button>

      <button
        class="relative flex items-center justify-center w-8 h-8 cursor-pointer rounded-full hover:bg-base-300/50 transition-colors z-10"
        phx-click={JS.dispatch("phx:set-theme")}
        data-phx-theme="dark"
        title="Dark theme"
      >
        <.icon name="hero-moon-micro" class="size-4 [[data-theme=dark]_&]:text-primary" />
      </button>
    </div>
    """
  end

  @doc """
  Provides a language switcher for i18n support.
  """
  attr :locale, :string, required: true

  def locale_switcher(assigns) do
    ~H"""
    <div class="dropdown dropdown-end">
      <div tabindex="0" role="button" class="btn btn-ghost btn-sm">
        <.icon name="hero-language" class="size-5" />
        <span class="uppercase">{@locale}</span>
      </div>
      <ul
        tabindex="0"
        class="dropdown-content menu bg-base-200 rounded-box z-[1] w-32 p-2 shadow mt-2"
      >
        <li>
          <a href="?locale=en" class={[@locale == "en" && "active"]}>
            English
          </a>
        </li>
        <li>
          <a href="?locale=fr" class={[@locale == "fr" && "active"]}>
            Français
          </a>
        </li>
      </ul>
    </div>
    """
  end

  @doc """
  Renders a navigation link.
  """
  attr :href, :string, required: true
  attr :method, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def nav_link(assigns) do
    ~H"""
    <.link
      href={@href}
      method={@method}
      class={[
        "px-4 py-2 text-sm font-medium",
        "text-base-content hover:text-[#85b4cf]",
        "transition-colors",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a primary button for navigation.
  """
  attr :href, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def nav_button_primary(assigns) do
    ~H"""
    <.link
      href={@href}
      class={[
        "px-5 py-2 text-sm font-semibold",
        "bg-[#e88e19] text-white rounded-lg",
        "hover:bg-[#d17d15] hover:shadow-md",
        "transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders the navbar logo link.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def nav_logo(assigns) do
    ~H"""
    <.link
      navigate={~p"/"}
      class={[
        "text-2xl font-bold",
        "text-[#85b4cf] hover:text-[#6a94ab]",
        "transition-colors",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end
end
