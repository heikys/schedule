defmodule ScheduleWeb.Components.MultiSelect do
  @moduledoc """
  A reusable component for multi-select functionality with search and dialog.

  This component provides:
  - A button to open a selection dialog
  - Search functionality within the dialog
  - Multiple selection with checkboxes
  - Display of selected items with remove buttons
  - Form integration for hidden inputs

  ## Usage

      <.live_component
        module={ScheduleWeb.Components.MultiSelect}
        id="product-selector"
        options={@product_options}
        selected_items={get_selected_products(@form)}
        field_name="discount_template[restrictions][products]"
        title="Productos permitidos"
        description="Selecciona los productos que pueden usar este descuento."
        button_text="Seleccionar productos"
        search_placeholder="Buscar productos..."
        empty_state_title="No hay productos seleccionados"
        empty_state_description="El descuento se aplicará a todos los productos"
        read_only={false}
        on_change="multi_select_changed"
      />
  """

  use ScheduleWeb, :live_component

  alias Phoenix.LiveView.JS
  alias ScheduleWeb.CoreComponents

  import SaladUI.AlertDialog
  # import SaladUI.Button
  # import SaladUI.Input

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:filtered_options, [])
      |> assign(:selected_items, [])

    {:ok, socket}
  end

  @impl true
  def update(assigns, socket) do
    # Validate required assigns
    unless Map.has_key?(assigns, :options), do: raise(ArgumentError, "options is required")
    unless Map.has_key?(assigns, :id), do: raise(ArgumentError, "id is required")

    # Required assigns
    options = assigns.options
    selected_items = Map.get(assigns, :selected_items, [])

    # Optional assigns with defaults
    title = Map.get(assigns, :title, "Select Items")
    description = Map.get(assigns, :description, "Choose items from the list.")
    button_text = Map.get(assigns, :button_text, "Select Items")
    search_placeholder = Map.get(assigns, :search_placeholder, "Search...")
    empty_state_title = Map.get(assigns, :empty_state_title, "No items selected")

    empty_state_description =
      Map.get(assigns, :empty_state_description, "All items will be included")

    # item_icon is now hardcoded in the template
    read_only = Map.get(assigns, :read_only, false)
    field_name = Map.get(assigns, :field_name, "items")
    on_change = Map.get(assigns, :on_change, nil)

    # Keep existing search_query and filtered_options if they exist, otherwise reset
    search_query = Map.get(socket.assigns, :search_query, "")

    filtered_options =
      if search_query == "", do: options, else: filter_options(options, search_query)

    socket =
      socket
      |> assign(:options, options)
      |> assign(:selected_items, selected_items)
      |> assign(:filtered_options, filtered_options)
      |> assign(:title, title)
      |> assign(:description, description)
      |> assign(:button_text, button_text)
      |> assign(:search_placeholder, search_placeholder)
      |> assign(:empty_state_title, empty_state_title)
      |> assign(:empty_state_description, empty_state_description)
      |> assign(:read_only, read_only)
      |> assign(:field_name, field_name)
      |> assign(:on_change, on_change)
      |> assign(:id, assigns.id)

    {:ok, socket}
  end

  @impl true
  def handle_event("search", %{"value" => query}, socket) do
    filtered_options = filter_options(socket.assigns.options, query)

    socket =
      socket
      |> assign(:search_query, query)
      |> assign(:filtered_options, filtered_options)

    {:noreply, socket}
  end

  @impl true
  def handle_event("toggle_item", %{"item-id" => item_id}, socket) do
    selected_items = socket.assigns.selected_items

    updated_selected_items =
      if item_id in selected_items do
        List.delete(selected_items, item_id)
      else
        [item_id | selected_items]
      end

    socket = assign(socket, :selected_items, updated_selected_items)

    {:noreply, socket}
  end

  @impl true
  def handle_event("apply_selection", _params, socket) do
    # Notify parent component of the selection change
    if socket.assigns.on_change do
      send(self(), {socket.assigns.on_change, socket.assigns.selected_items})
    end

    # Clear search and reset filtered options
    socket =
      socket
      |> assign(:search_query, "")
      |> assign(:filtered_options, socket.assigns.options)
      |> push_event("clear_search", %{target: "##{socket.assigns.id}-search"})

    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_item", %{"item-id" => item_id}, socket) do
    updated_selected_items = List.delete(socket.assigns.selected_items, item_id)

    # Notify parent component of the change
    if socket.assigns.on_change do
      send(self(), {socket.assigns.on_change, updated_selected_items})
    end

    socket = assign(socket, :selected_items, updated_selected_items)

    {:noreply, socket}
  end

  defp filter_options(options, query) when query == "" or is_nil(query), do: options

  defp filter_options(options, query) do
    query_lower = String.downcase(query)

    Enum.filter(options, fn option ->
      option.name
      |> String.downcase()
      |> String.contains?(query_lower)
    end)
  end
end
