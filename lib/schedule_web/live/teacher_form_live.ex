defmodule ScheduleWeb.TeacherFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher

  import Ecto.Query, only: [from: 2]

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       all_subjects: list_subjects(),
       teachers: list_teachers(),
       form: to_form(Teacher.changeset(%Teacher{}, %{})),
       valid_form?: false
     )}
  end

  @impl true
  def handle_event("validate", %{"teacher" => teacher_params}, socket) do
    changeset =
      Teacher.changeset(%Teacher{}, teacher_params)
      |> Ecto.Changeset.put_assoc(
        :subjects,
        preload_subjects(teacher_params["subject_ids"] || [])
      )
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
    changeset =
      %Teacher{}
      |> Teacher.changeset(teacher_params)
      |> Ecto.Changeset.put_assoc(
        :subjects,
        preload_subjects(teacher_params["subject_ids"] || [])
      )

    case Repo.insert(changeset) do
      {:ok, _teacher} ->
        {:noreply,
         socket
         |> put_flash(:info, "Profesor guardado correctamente.")
         |> assign(form: to_form(Teacher.changeset(%Teacher{}, %{})))
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

  defp list_teachers, do: Repo.all(Teacher) |> Repo.preload(:subjects)

  defp list_subjects, do: Repo.all(Subject)

  defp preload_subjects(nil), do: []

  defp preload_subjects(subject_ids) do
    subject_ids
    |> Enum.reject(&(&1 == ""))
    |> case do
      [] ->
        []

      ids ->
        Repo.all(from s in Subject, where: s.id in ^ids)
    end
  end
end
