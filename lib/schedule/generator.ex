defmodule Schedule.Generator do
  @moduledoc """
  Generates a school schedule using a backtracking algorithm.
  """

  alias Schedule.Repo
  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.SchoolConfig
  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment

  @doc """
  Generates a valid schedule for all groups.
  """
  def generate do
    # 1. Fetch all necessary data from the database
    groups = Repo.all(Group)
    config = Repo.get_by(SchoolConfig, []) |> Repo.preload(:time_slots)
    assignments = Repo.all(TeacherGroupSubjectAssignment)

    # 2. Prepare the data structures for the solver
    lessons_to_schedule = prepare_lessons(assignments)
    slots = prepare_slots(config, groups)
    high_frequency_subjects = high_frequency_subjects(assignments, config.days)

    initial_state = %{
      # The final schedule, group_id -> %{{day, slot_order} -> %{subject, teacher}}
      schedule: Enum.into(groups, %{}, &{&1.id, %{}}),
      # Keep track of teacher's availability: {teacher_id, day, slot_order}
      teacher_bookings: MapSet.new(),
      daily_subject_bookings: MapSet.new(),
      high_frequency_subjects: high_frequency_subjects
    }

    # 3. Run the backtracking solver
    case solve(lessons_to_schedule, slots, initial_state) do
      {:ok, final_state} -> {:ok, final_state.schedule}
      :error -> {:error, "Could not find a valid schedule."}
    end
  end

  @doc """
  The main backtracking function.

  It tries to place one lesson at a time. If it can't place a lesson,
  it backtracks and tries a different slot.
  """
  defp solve([], _slots, state) do
    # Base case: all lessons have been scheduled successfully.
    {:ok, state}
  end

  defp solve([lesson | rest_lessons], slots, state) do
    # Recursive step: try to place the current lesson in all available slots.
    find_and_place_lesson(lesson, slots, rest_lessons, state)
  end

  defp find_and_place_lesson(lesson, [slot | rest_slots], rest_lessons, state) do
    if can_place?(lesson, slot, state) do
      # If the lesson can be placed, place it and move to the next lesson.
      new_state = place_lesson(lesson, slot, state)

      case solve(rest_lessons, rest_slots, new_state) do
        {:ok, final_state} ->
          {:ok, final_state}

        :error ->
          # This path led to a dead end. Backtrack and try the next slot.
          find_and_place_lesson(lesson, rest_slots, rest_lessons, state)
      end
    else
      # This slot is not valid, try the next one.
      find_and_place_lesson(lesson, rest_slots, rest_lessons, state)
    end
  end

  defp find_and_place_lesson(_lesson, [], _rest_lessons, _state) do
    # If we've run out of slots for the current lesson, this path is invalid.
    :error
  end

  defp can_place?(lesson, slot, state) do
    # A lesson can be placed if:
    # 1. The group for the lesson matches the slot's group.
    # 2. The teacher is not already booked for that day and time slot.
    # 3. The subject has not already been taught to that group on that day,
    #    unless it's a high-frequency subject.
    teacher_booking = {lesson.teacher_id, slot.day, slot.order}
    daily_subject_booking = {lesson.group_id, slot.day, lesson.subject_id}

    is_high_frequency? =
      MapSet.member?(state.high_frequency_subjects, {lesson.group_id, lesson.subject_id})

    subject_already_on_day? = MapSet.member?(state.daily_subject_bookings, daily_subject_booking)

    lesson.group_id == slot.group_id &&
      not MapSet.member?(state.teacher_bookings, teacher_booking) &&
      (is_high_frequency? || not subject_already_on_day?)
  end

  @doc """
  Places a lesson in the schedule and updates the state.
  """
  defp place_lesson(lesson, slot, state) do
    # Add the teacher booking to the set of bookings.
    teacher_booking = {lesson.teacher_id, slot.day, slot.order}
    new_teacher_bookings = MapSet.put(state.teacher_bookings, teacher_booking)

    # Add the daily subject booking.
    daily_subject_booking = {lesson.group_id, slot.day, lesson.subject_id}
    new_daily_subject_bookings = MapSet.put(state.daily_subject_bookings, daily_subject_booking)

    # Add the lesson to the group's schedule.
    group_schedule = state.schedule[lesson.group_id]
    slot_key = {slot.day, slot.order}

    new_group_schedule =
      Map.put(group_schedule, slot_key, %{
        subject_id: lesson.subject_id,
        teacher_id: lesson.teacher_id
      })

    new_schedule = Map.put(state.schedule, lesson.group_id, new_group_schedule)

    %{
      state
      | schedule: new_schedule,
        teacher_bookings: new_teacher_bookings,
        daily_subject_bookings: new_daily_subject_bookings
    }
  end

  @doc """
  Creates a flat list of all individual lessons that need to be scheduled.
  e.g., 3 hours/week of Math for group A becomes three separate "Math for group A" lessons.
  """
  defp prepare_lessons(assignments) do
    for assignment <- assignments,
        _ <- 1..assignment.hours_per_week do
      %{
        group_id: assignment.group_id,
        subject_id: assignment.subject_id,
        teacher_id: assignment.teacher_id
      }
    end
  end

  @doc """
  Creates a list of all available time slots for all groups.
  """
  defp prepare_slots(config, groups) do
    days = 1..config.days
    slot_orders = 1..config.slots_per_day

    for group <- groups,
        day <- days,
        order <- slot_orders do
      %{
        group_id: group.id,
        day: day,
        order: order
      }
    end
  end

  defp high_frequency_subjects(assignments, config_days) do
    assignments
    |> Enum.filter(&(&1.hours_per_week > config_days))
    |> Enum.map(&{&1.group_id, &1.subject_id})
    |> MapSet.new()
  end
end
