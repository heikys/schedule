defmodule ScheduleWeb.CourseFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Course
  alias Schedule.Repo.Schema.Group

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       courses: list_courses(),
       form: new_course_form(),
       step: 1,
       valid_form?: false
     )}
  end

  @impl true
  def handle_event("add_group", _, socket) do
    {:noreply, update(socket, :form, &add_group_to_form/1)}
  end

  @impl true
  def handle_event("delete_group", %{"index" => index_str}, socket) do
    index = String.to_integer(index_str)
    {:noreply, update(socket, :form, &remove_group_from_form(&1, index))}
  end

  @impl true
  def handle_event("validate", %{"course" => course_params}, socket) do
    form =
      %Course{}
      |> Course.changeset(course_params)
      |> Map.put(:action, :validate)
      |> to_form(as: "course")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:valid_form?, form.source.valid?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_course", %{"course" => course_params}, socket) do
    course_params = filter_empty_groups(course_params)
    changeset = Course.changeset(%Course{}, course_params)

    case Repo.insert(changeset) do
      {:ok, _course} ->
        {:noreply,
         socket
         |> put_flash(:info, "Curso y grupos guardados correctamente.")
         |> assign(form: new_course_form())
         |> assign(courses: list_courses())
         |> assign(:valid_form?, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "course"))}
    end
  end

  defp list_courses do
    Repo.all(Course) |> Repo.preload(:groups)
  end

  defp new_course_form do
    Course.changeset(%Course{}, %{days: 5, slots_per_day: 6, groups: [%{}]})
    |> to_form(as: "course")
  end

  defp add_group_to_form(form) do
    groups = Ecto.Changeset.get_field(form.source, :groups, [])
    updated_groups = groups ++ [Ecto.Changeset.change(%Group{})]

    form.source
    |> Ecto.Changeset.put_assoc(:groups, updated_groups)
    |> to_form(as: "course")
  end

  defp remove_group_from_form(form, index) do
    groups = Ecto.Changeset.get_field(form.source, :groups, [])
    updated_groups = List.delete_at(groups, index)

    form.source
    |> Ecto.Changeset.put_assoc(:groups, updated_groups)
    |> to_form(as: "course")
  end

  defp filter_empty_groups(course_params) do
    update_in(course_params["groups"], fn
      nil ->
        []

      groups ->
        groups
        |> Map.values()
        |> Enum.filter(&(&1["name"] |> to_string() |> String.trim() != ""))
    end)
  end
end
