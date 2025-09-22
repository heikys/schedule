defmodule ScheduleWeb.Components.Typeahead do
  use ScheduleWeb, :live_component

  slot :item, required: true

  @impl true
  def mount(socket) do
    socket =
      socket
      |> assign(:selected_item, nil)
      |> assign(:items, [])
      |> assign(
        :form,
        to_form(
          Schedule.Repo.Schema.TeacherGroupSubjectAssignment.changeset(
            %Schedule.Repo.Schema.TeacherGroupSubjectAssignment{},
            %{}
          )
        )
      )

    {:ok, socket}
  end

  @impl true
  def update(%{items: items} = _assigns, socket) do
    {:ok, assign(socket, items: items)}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(assigns)
      |> assign_new(:form, fn ->
        to_form(%{})
      end)
      |> assign_new(:value, fn ->
        nil
      end)
      |> assign_new(:selected_item, fn ->
        nil
      end)
      |> assign(:id, assigns.id)
      |> assign(:field_name, assigns.field_name)
      |> assign(:placeholder, assigns.placeholder)
      # |> assign(:items, assigns.items)
      |> assign(:on_click, assigns.on_click)
      |> assign(:on_search, assigns.on_search)
      |> assign(:on_select, assigns.on_select)

    {:ok, socket}
  end

  @impl true
  def handle_event("click", _, socket) do
    {func, id} = socket.assigns.on_click
    send(self(), {func, id})

    {:noreply, socket}
  end

  @impl true
  def handle_event("search", %{"value" => value}, socket) do
    {func, id} = socket.assigns.on_search
    send(self(), {func, value, id})

    {:noreply, assign(socket, :value, value)}
  end

  @impl true
  def handle_event("select", %{"id" => item_id}, socket) do
    selected_item =
      Enum.find(socket.assigns.items, fn item ->
        to_string(item.id) == item_id
      end)

    send(self(), {socket.assigns.on_select, item_id})

    socket =
      socket
      |> assign(:selected_item, selected_item)
      |> assign(:items, [])
      |> assign(:value, nil)

    {:noreply, socket}
  end

  @impl true
  def handle_event("clear", _, socket) do
    send(self(), {socket.assigns.on_select, ""})
    {:noreply, assign(socket, selected_item: nil, value: nil)}
  end

  @doc """
  Renders the typeahead component.
  ## Assigns

    <!-- * `:subtitle` - The subtitle of the typeahead component. -->
    * `:field` - The name the input should have.
    * `:placeholder` - The placeholder text for the input field.
    * `:items` - The list of items to display in the dropdown.
    * `:form` - The form data structure.
    * `:value` - The current value of the input field.
    * `:on_click` - The event name to trigger on click input.
    * `:on_search` - The event name to trigger on search input change.
    * `:on_select` - The event name to trigger on item selection.
    * `:item` - A slot for rendering each item in the dropdown.
  """

  @impl true
  def render(assigns) do
    field_name = String.to_atom(assigns.field_name)

    ~H"""
    <div class="relative">
      <%= if @selected_item do %>
        <div class="flex items-center justify-between w-full border border-gray-300 rounded-md bg-white px-3 py-2 shadow-sm">
          <span class="text-gray-700">{@selected_item.name}</span>
          <button
            type="button"
            phx-click="clear"
            phx-target={@myself}
            class="ml-2 p-1 rounded-full text-gray-400 hover:text-gray-600 hover:bg-gray-100 focus:outline-none focus:ring-2 focus:ring-primary-light transition-colors"
            aria-label="Limpiar selección de asignatura"
          >
            <.icon name="x-mark" class="w-4 h-4" />
          </button>
          <input
            type="hidden"
            name={Phoenix.HTML.Form.input_name(@form, field_name)}
            value={@selected_item.id}
          />
        </div>
      <% else %>
        <div>
          <.input
            field={@form[field_name]}
            type="text"
            placeholder={@placeholder}
            phx-click="click"
            phx-keyup="search"
            phx-target={@myself}
            phx-debounce="300"
            value={@value}
            autocomplete="off"
            class="w-full border-gray-300 rounded-md shadow-sm focus:border-primary focus:ring-primary transition outline-primary"
          />

          <ul
            :if={not Enum.empty?(@items)}
            class="absolute z-10 w-full bg-white text-gray-700 border border-gray-200 rounded-md shadow-lg mt-2 max-h-60 overflow-y-auto transition-opacity duration-200 ease-in-out"
          >
            <li
              :for={item <- @items}
              tabindex="0"
              class="px-4 py-2.5 cursor-pointer focus:outline-none hover:bg-primary hover:text-white transition-colors duration-150"
              phx-click="select"
              phx-value-id={item.id}
              phx-target={@myself}
            >
              <span>{item.name}</span>
            </li>
          </ul>

          <div :if={@value && Enum.empty?(@items)} class="text-sm text-gray-500 px-4 py-2.5 mt-2">
            {gettext("No results")}
          </div>
        </div>
      <% end %>
    </div>
    """
  end
end
