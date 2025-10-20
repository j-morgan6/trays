defmodule TraysWeb.MerchantComponents do
  use Phoenix.Component
  import TraysWeb.CoreComponents

  @doc """
  Renders a page header card with gradient.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def page_header(assigns) do
    ~H"""
    <div class={[
      "bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders the gradient header section.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def header_gradient(assigns) do
    ~H"""
    <div class={["bg-gradient-to-br from-[#85b4cf] to-[#6a94ab] px-6 py-8", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a header icon container.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def header_icon(assigns) do
    ~H"""
    <div class={[
      "w-16 h-16 bg-white/20 backdrop-blur-sm rounded-xl",
      "flex items-center justify-center flex-shrink-0",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a stats section.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def stats_section(assigns) do
    ~H"""
    <div class={["p-6 bg-base-content/5", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a stat icon container.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def stat_icon(assigns) do
    ~H"""
    <div class={["w-12 h-12 bg-[#85b4cf]/10 rounded-lg flex items-center justify-center", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a content card.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def card(assigns) do
    ~H"""
    <div class={[
      "bg-white rounded-xl shadow-sm border border-base-content/10 overflow-hidden",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a card header.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def card_header(assigns) do
    ~H"""
    <div class={["px-6 py-4 border-b border-base-content/10", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders an empty state container.
  """
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def empty_state(assigns) do
    ~H"""
    <div class={["px-6 py-12 text-center", @class]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a table header cell.
  """
  attr :align, :string, default: "left"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def th(assigns) do
    ~H"""
    <th class={[
      "px-6 py-4 text-xs font-semibold text-white uppercase tracking-wider",
      @align == "left" && "text-left",
      @align == "center" && "text-center",
      @align == "right" && "text-right",
      @class
    ]}>
      {render_slot(@inner_block)}
    </th>
    """
  end

  @doc """
  Renders an avatar with icon.
  """
  attr :color, :string, default: "blue"
  attr :size, :string, default: "md"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def avatar(assigns) do
    ~H"""
    <div class={[
      "flex-shrink-0 rounded-lg flex items-center justify-center",
      @size == "sm" && "w-10 h-10",
      @size == "md" && "w-12 h-12",
      @color == "blue" && "bg-gradient-to-br from-[#85b4cf] to-[#6a94ab]",
      @color == "orange" && "bg-gradient-to-br from-[#e88e19] to-[#d17d15]",
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a badge.
  """
  attr :color, :string, default: "blue"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def badge(assigns) do
    ~H"""
    <span class={[
      "inline-flex items-center gap-1 px-2.5 py-1 rounded-full text-sm font-medium",
      @color == "blue" && "bg-[#85b4cf]/10 text-[#85b4cf]",
      @color == "orange" && "bg-[#e88e19]/10 text-[#e88e19]",
      @class
    ]}>
      {render_slot(@inner_block)}
    </span>
    """
  end

  @doc """
  Renders a small action button.
  """
  attr :navigate, :string, default: nil
  attr :phx_click, :any, default: nil
  attr :data_confirm, :string, default: nil
  attr :color, :string, default: "blue"
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_action(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      phx-click={@phx_click}
      data-confirm={@data_confirm}
      class={[
        "inline-flex items-center gap-1 px-3 py-1.5 text-xs font-medium",
        "border rounded-lg transition-all duration-200",
        @color == "blue" && "text-[#85b4cf] hover:text-white hover:bg-[#85b4cf] border-[#85b4cf]",
        @color == "orange" && "text-[#e88e19] hover:text-white hover:bg-[#e88e19] border-[#e88e19]",
        @color == "red" && "text-red-600 hover:text-white hover:bg-red-600 border-red-600",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a primary button.
  """
  attr :navigate, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_primary(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "inline-flex items-center gap-2 px-4 py-2 text-sm font-medium",
        "text-white bg-gradient-to-br from-[#85b4cf] to-[#6a94ab]",
        "rounded-lg hover:shadow-lg transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a secondary button with border.
  """
  attr :navigate, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_secondary(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "inline-flex items-center gap-2 px-4 py-2 text-sm font-medium",
        "text-white hover:bg-white/20 border border-white/50",
        "rounded-lg transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a back link.
  """
  attr :navigate, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def back_link(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "inline-flex items-center gap-2 text-sm",
        "text-base-content/70 hover:text-[#85b4cf] transition-colors",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a cancel button.
  """
  attr :navigate, :string, required: true
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_cancel(assigns) do
    ~H"""
    <.link
      navigate={@navigate}
      class={[
        "inline-flex items-center gap-2 px-6 py-2.5 text-sm font-medium",
        "text-base-content/70 hover:text-base-content hover:bg-base-content/5",
        "border border-base-content/20 rounded-lg transition-all duration-200",
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </.link>
    """
  end

  @doc """
  Renders a submit button.
  """
  attr :disabled, :boolean, default: false
  attr :phx_disable_with, :string, default: nil
  attr :class, :string, default: ""
  slot :inner_block, required: true

  def btn_submit(assigns) do
    ~H"""
    <button
      type="submit"
      disabled={@disabled}
      phx-disable-with={@phx_disable_with}
      class={[
        "inline-flex items-center gap-2 px-8 py-3 text-sm font-semibold rounded-lg transition-all duration-200",
        "focus:outline-none focus:ring-2 focus:ring-[#e88e19] focus:ring-offset-2",
        if(@disabled,
          do: "text-base-content/40 bg-base-content/10 cursor-not-allowed",
          else:
            "text-white bg-gradient-to-br from-[#e88e19] to-[#d17d15] hover:shadow-lg hover:scale-105 cursor-pointer"
        ),
        @class
      ]}
    >
      {render_slot(@inner_block)}
    </button>
    """
  end
end
