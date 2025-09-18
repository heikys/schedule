defmodule ScheduleWeb.SubjectFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Subject

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       subjects: list_subjects(),
       form: to_form(Subject.changeset(%Subject{}, %{})),
       valid_form?: false
     )}
  end

  @impl true
  def handle_event("validate", %{"subject" => subject_params}, socket) do
    form =
      %Subject{}
      |> Subject.changeset(subject_params)
      |> Map.put(:action, :validate)
      |> to_form(as: "subject")

    socket =
      socket
      |> assign(:form, form)
      |> assign(:valid_form?, form.source.valid?)

    {:noreply, socket}
  end

  @impl true
  def handle_event("add_subject", %{"subject" => subject_params}, socket) do
    case Repo.insert(Subject.changeset(%Subject{}, subject_params)) do
      {:ok, _subject} ->
        {:noreply,
         socket
         |> put_flash(:info, "Asignatura guardada correctamente.")
         |> assign(form: to_form(Subject.changeset(%Subject{}, %{})))
         |> assign(subjects: list_subjects())
         |> assign(:valid_form?, false)}

      {:error, changeset} ->
        {:noreply, assign(socket, form: to_form(changeset, as: "subject"))}
    end
  end

  @impl true
  def handle_event("delete_subject", %{"id" => id}, socket) do
    subject = Repo.get!(Subject, id)
    Repo.delete!(subject)

    {:noreply,
     socket
     |> put_flash(:info, "Asignatura eliminada correctamente.")
     |> assign(subjects: list_subjects())}
  end

  defp list_subjects do
    Repo.all(Subject)
  end
end
