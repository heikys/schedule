defmodule ScheduleWeb.Components.Typeahead do
  use ScheduleWeb, :live_component

  slot :item, required: true

  @impl true
  def mount(socket) do
    socket =
      socket
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
  def handle_event("select", %{"id" => id}, socket) do
    send(self(), {socket.assigns.on_select, id})

    {:noreply, socket}
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
    <div>
      <div class="space-y-6">
        <.input
          field={@form[field_name]}
          type="text"
          placeholder={@placeholder}
          phx-click="click"
          phx-keyup="search"
          phx-target={@myself}
          phx-debounce="300"
        />

        <ul>
          <li
            :for={item <- @items}
            tabindex="0"
            class="border-b py-1 last:border-none dark:border-zinc-700 cursor-pointer focus:outline-none focus:ring focus:ring-blue-300 focus:border-blue-500"
            phx-click="select"
            phx-value-id={item.id}
            phx-target={@myself}
          >
            {item.name}
          </li>
        </ul>

        <div :if={@value && Enum.empty?(@items)}>
          {gettext("No results")}
        </div>
      </div>
    </div>
    """
  end
end
