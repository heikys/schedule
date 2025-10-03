defmodule ScheduleWeb.SchoolConfigLive do
  use ScheduleWeb, :live_view

  alias Schedule.SchoolConfig.Repo, as: SchoolConfigRepo
  alias Schedule.Repo.Schema.TimeSlot
  import Ecto.Changeset, only: [get_field: 2]

  def mount(_params, _session, socket) do
    # In the future, we'll have to filter by school id
    school_config =
      case SchoolConfigRepo.list_school_configs() do
        [] ->
          {:ok, sc} = SchoolConfigRepo.create_school_config(%{days: 5, slots_per_day: 6})
          sc

        [sc | _] ->
          sc
      end
      |> Schedule.Repo.preload(:time_slots)

    changeset = SchoolConfigRepo.change_school_config(school_config)

    socket =
      socket
      |> assign(:school_config, school_config)
      |> assign(:form, to_form(changeset))
      |> adjust_time_slots(school_config.slots_per_day)

    {:ok, socket}
  end

  def handle_event("validate", %{"school_config" => params}, socket) do
    changeset =
      socket.assigns.school_config
      |> SchoolConfigRepo.change_school_config(params)
      |> Map.put(:action, :validate)

    slots_per_day = get_field(changeset, :slots_per_day)

    socket =
      socket
      |> assign(:form, to_form(changeset))
      |> adjust_time_slots(slots_per_day)

    {:noreply, socket}
  end

  def handle_event("save", %{"school_config" => params}, socket) do
    case SchoolConfigRepo.update_school_config(socket.assigns.school_config, params) do
      {:ok, school_config} ->
        {:noreply,
         socket
         |> put_flash(:info, "School configuration updated successfully.")
         |> assign(:school_config, school_config)
         |> assign(:changeset, SchoolConfigRepo.change_school_config(school_config))}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp adjust_time_slots(socket, slots_per_day) do
    source = socket.assigns.form.source
    current_time_slots = Ecto.Changeset.get_field(source, :time_slots)
    current_count = Enum.count(current_time_slots)

    if slots_per_day > current_count do
      new_slots_needed = slots_per_day - current_count

      {start_time, end_time} =
        case List.last(current_time_slots) do
          nil -> {~T[07:00:00], ~T[07:55:00]}
          last_time_slot -> {last_time_slot.start_time, last_time_slot.end_time}
        end

      new_slots = build_new_slots(start_time, end_time, new_slots_needed)

      changeset =
        Ecto.Changeset.put_assoc(source, :time_slots, current_time_slots ++ new_slots)
        |> to_form()

      assign(socket, :form, changeset)
    else
      new_slots = Enum.take(current_time_slots, slots_per_day)
      changeset = Ecto.Changeset.put_assoc(source, :time_slots, new_slots) |> to_form()
      assign(socket, :form, changeset)
    end
  end

  defp build_new_slots(start_time, end_time, count) do
    for index <- 1..count do
      %TimeSlot{
        start_time: Time.add(start_time, index, :hour),
        end_time: Time.add(end_time, index, :hour),
        order: index - 1
      }
    end
  end
end
