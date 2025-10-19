defmodule TraysWeb.PageHTML do
  @moduledoc """
  This module contains pages rendered by PageController.

  See the `page_html` directory for all templates available.
  """
  use TraysWeb, :html

  embed_templates "page_html/*"

  @doc """
  Renders a hero badge (e.g., Coming Soon badge).
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def hero_badge(assigns) do
    ~H"""
    <div class={[
      "inline-flex items-center gap-2 px-4 py-2",
      "bg-[#e88e19]/10 rounded-full border-2 border-[#e88e19]",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a hero title.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def hero_title(assigns) do
    ~H"""
    <h1 class={[
      "text-5xl sm:text-6xl lg:text-7xl font-bold",
      "text-base-content tracking-tight",
      @class
    ]}>
      {render_slot(@inner_block)}
    </h1>
    """
  end

  @doc """
  Renders a hero subtitle.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def hero_subtitle(assigns) do
    ~H"""
    <p class={[
      "text-xl sm:text-2xl text-base-content/80",
      "max-w-3xl mx-auto leading-relaxed",
      @class
    ]}>
      {render_slot(@inner_block)}
    </p>
    """
  end

  @doc """
  Renders a primary call-to-action button.
  """
  attr :navigate, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_cta_primary(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "px-8 py-4 text-lg font-semibold",
        "bg-[#e88e19] text-white rounded-lg",
        "hover:bg-[#d17d15] hover:shadow-xl",
        "transform hover:-translate-y-0.5",
        "transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a secondary call-to-action button.
  """
  attr :navigate, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_cta_secondary(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "px-8 py-4 text-lg font-semibold",
        "bg-white text-[#53585d] rounded-lg",
        "border-2 border-[#85b4cf]",
        "hover:bg-[#85b4cf]/5 hover:border-[#85b4cf] hover:shadow-lg",
        "transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a feature card.
  """
  attr :color, :string, default: "blue"
  attr :icon, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def feature_card(assigns) do
    ~H"""
    <div class={[
      "rounded-xl p-8 border-2 space-y-4",
      "hover:shadow-xl transform hover:-translate-y-1",
      "transition-all duration-200",
      @color == "blue" && "bg-gradient-to-br from-[#85b4cf]/5 to-white border-[#85b4cf]/20 hover:border-[#85b4cf]",
      @color == "orange" && "bg-gradient-to-br from-[#e88e19]/5 to-white border-[#e88e19]/30 hover:border-[#e88e19]",
      @class
    ]}>
      <div class={[
        "w-16 h-16 rounded-xl flex items-center justify-center shadow-lg",
        @color == "blue" && "bg-[#85b4cf]",
        @color == "orange" && "bg-[#e88e19]"
      ]}>
        <.icon name={@icon} class="size-8 text-white" />
      </div>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a feature card title.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def feature_title(assigns) do
    ~H"""
    <h3 class={["text-xl font-bold text-base-content", @class]}>
      {render_slot(@inner_block)}
    </h3>
    """
  end

  @doc """
  Renders feature card description text.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def feature_text(assigns) do
    ~H"""
    <p class={["text-base-content/70 leading-relaxed", @class]}>
      {render_slot(@inner_block)}
    </p>
    """
  end
end
