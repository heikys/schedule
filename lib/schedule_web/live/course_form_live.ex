defmodule ScheduleWeb.CourseFormLive do
  use ScheduleWeb, :live_view

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Course

  def mount(_params, _session, socket) do
    {:ok,
     assign(socket,
       courses: Repo.all(Course),
       changeset: Course.changeset(%Course{}, %{days: 5, slots_per_day: 5}),
       step: 1,
       course_name: ""
     )}
  end

  def handle_event("add_course", %{"course" => raw_course}, socket) do
    changeset = Course.changeset(%Course{}, raw_course)

    if changeset.valid? do
      {:ok, course} = Repo.insert(changeset)

      {:noreply,
       socket
       |> assign(:courses, socket.assigns.courses ++ [course])
       |> assign(:changeset, Course.changeset(%Course{}, %{}))}
    else
      {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  def handle_event("next_step", _params, socket) do
    {:noreply, assign(socket, step: socket.assigns.step + 1)}
  end

  def handle_event("validate_course", %{"course" => course_params}, socket) do
    changeset =
      %Course{}
      |> Course.changeset(course_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, changeset: changeset)}
  end
end
