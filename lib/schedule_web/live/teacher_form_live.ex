defmodule ScheduleWeb.TeacherFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Teacher

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       teachers: list_teachers(),
       form: to_form(Teacher.changeset(%Teacher{}, %{})),
       valid_form?: false
     )}
  end

  @impl true
  def handle_event("validate", %{"teacher" => teacher_params}, socket) do
    form =
      %Teacher{}
      |> Teacher.changeset(teacher_params)
      |> Map.put(:action, :validate)
      |> to_form(as: "teacher")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:valid_form?, form.source.valid?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_teacher", %{"teacher" => teacher_params}, socket) do
    case Repo.insert(Teacher.changeset(%Teacher{}, teacher_params)) do
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

  defp list_teachers do
    Repo.all(Teacher)
  end
end
