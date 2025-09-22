defmodule ScheduleWeb.TeacherFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Course
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher
  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment
  alias ScheduleWeb.Components.Typeahead

  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       all_subjects: [],
       #  all_subjects: list_subjects(),
       all_courses_with_groups: list_courses_with_groups(),
       teachers: list_teachers(),
       # Inicializamos con una asignación para que se muestre una fila
       form:
         to_form(
           Teacher.changeset(%Teacher{}, %{assignments: [%TeacherGroupSubjectAssignment{}]})
         ),
       valid_form?: false
     )}
  end

  @impl true
  def handle_event("validate", %{"teacher" => teacher_params}, socket) do
    # Remove empty assignments that can be sent by the form

    teacher_params =
      case teacher_params["assignments"] do
        nil ->
          update_in(teacher_params["assignments"], fn _ -> [%TeacherGroupSubjectAssignment{}] end)

        _otherwise ->
          update_in(teacher_params["assignments"], fn assignments ->
            Enum.reject(assignments, &(&1["subject_id"] == ""))
          end)
      end

    changeset =
      Teacher.changeset(%Teacher{}, teacher_params)
      |> Map.put(:action, :validate)

    form = to_form(changeset, as: "teacher")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:valid_form?, form.source.valid?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_teacher", %{"teacher" => teacher_params}, socket) do
    # Remove empty assignments that can be sent by the form
    teacher_params =
      update_in(teacher_params["assignments"], fn assignments ->
        Enum.reject(assignments, &(&1["subject_id"] == ""))
      end)

    changeset =
      %Teacher{}
      |> Teacher.changeset(teacher_params)

    case Repo.insert(changeset) do
      {:ok, _teacher} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profesor guardado correctamente.")
         |> assign(
           form: to_form(Teacher.changeset(%Teacher{}, %{assignments: [%{}]})),
           valid_form?: false
         )
         |> assign(teachers: list_teachers())
         |> assign(:valid_form?, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "teacher"))}
    end
  end

  @impl true
  def handle_event("delete_teacher", %{"id" => id}, socket) do
    teacher = Repo.get!(Teacher, id)
    Repo.delete!(teacher)

    {:noreply,
     socket
     |> put_flash(:info, "Profesor eliminado correctamente.")
     |> assign(teachers: list_teachers())}
  end

  @impl true
  def handle_event("add-assignment", _params, socket) do
    # La forma correcta de añadir un input dinámico es actualizar el changeset
    # y volver a generar el formulario con `to_form`.
    existing_assignments = Ecto.Changeset.get_field(socket.assigns.form.source, :assignments)
    new_assignments = (existing_assignments || []) ++ [%{}]

    new_changeset =
      Ecto.Changeset.put_change(socket.assigns.form.source, :assignments, new_assignments)

    {:noreply, assign(socket, form: to_form(new_changeset))}
  end

  @impl true
  def handle_event("remove-assignment", %{"index" => index}, socket) do
    index = String.to_integer(index)
    existing_assignments = Ecto.Changeset.get_field(socket.assigns.form.source, :assignments)
    new_assignments = List.delete_at(existing_assignments, index)

    new_changeset =
      Ecto.Changeset.put_change(socket.assigns.form.source, :assignments, new_assignments)

    {:noreply, assign(socket, form: to_form(new_changeset))}
  end

  @impl true
  def handle_info({:click_subject, assignment_id}, socket) do
    subjects = list_subjects()

    send_update(Typeahead, id: assignment_id, items: subjects)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:search_subject, value, id}, socket) do
    subjects =
      list_subjects()
      |> Enum.filter(fn subject ->
        String.contains?(String.downcase(subject.name), String.downcase(value))
      end)

    send_update(Typeahead, id: id, items: subjects)

    {:noreply, socket}
  end

  @impl true
  def handle_info({{:subject_selected, _assignment_id}, subject_id}, socket) do
    selected_subject = Repo.get!(Subject, subject_id)

    IO.inspect(subject_id, label: "Selected subject ID")

    socket = assign(socket, selected_subject: selected_subject)
    # {:noreply, push_patch(socket, to: ~p"/teachers/new")}
    {:noreply, socket}
  end

  defp list_teachers, do: Repo.all(Teacher) |> Repo.preload(:subjects)

  defp list_subjects do
    Enum.map(Repo.all(Subject), fn %{id: id, name: name} -> %{id: id, name: name} end)
  end

  defp list_courses_with_groups,
    do: Repo.all(from c in Course, order_by: c.name, preload: [:groups])
end
