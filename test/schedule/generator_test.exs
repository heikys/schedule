defmodule Schedule.GeneratorTest do
  use Schedule.DataCase, async: true

  alias Schedule.Generator
  alias Schedule.Repo.Schema.Course
  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.SchoolConfig
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher
  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment
  alias Schedule.Repo.Schema.TimeSlot

  describe "generate/0" do
    setup do
      # 1. Create all the necessary data for a simple scenario
      config =
        %SchoolConfig{}
        |> SchoolConfig.changeset(%{days: 5, slots_per_day: 6})
        |> Repo.insert!()

      # Create time slots associated with the config
      for order <- 1..config.slots_per_day do
        Repo.insert!(%TimeSlot{
          order: order,
          start_time: ~T[08:00:00],
          end_time: ~T[09:00:00],
          school_config_id: config.id
        })
      end

      course = Repo.insert!(%Course{name: "1º ESO"})
      group_a = Repo.insert!(%Group{name: "A", course_id: course.id})
      group_b = Repo.insert!(%Group{name: "B", course_id: course.id})

      math = Repo.insert!(%Subject{name: "Matemáticas", code: "MAT"})
      lang = Repo.insert!(%Subject{name: "Lengua", code: "LCL"})

      teacher1 = Repo.insert!(%Teacher{name: "Profesor 1"})
      teacher2 = Repo.insert!(%Teacher{name: "Profesor 2"})

      # Assignments
      # Group A: 3h Math (T1), 2h Lang (T2) -> 5 total hours
      Repo.insert!(%TeacherGroupSubjectAssignment{
        teacher_id: teacher1.id,
        group_id: group_a.id,
        subject_id: math.id,
        hours_per_week: 3
      })

      Repo.insert!(%TeacherGroupSubjectAssignment{
        teacher_id: teacher2.id,
        group_id: group_a.id,
        subject_id: lang.id,
        hours_per_week: 2
      })

      # Group B: 4h Math (T2) -> 4 total hours
      Repo.insert!(%TeacherGroupSubjectAssignment{
        teacher_id: teacher2.id,
        group_id: group_b.id,
        subject_id: math.id,
        hours_per_week: 4
      })

      %{group_a: group_a, group_b: group_b}
    end

    test "generates a valid schedule that respects constraints", %{
      group_a: group_a,
      group_b: group_b
    } do
      # 2. Run the generator
      assert {:ok, schedule} = Generator.generate()

      # 3. (Opcional) Imprimir el horario en la consola para inspección visual
      print_schedule(schedule)

      # 4. Verify the generated schedule
      # Check that schedules for both groups were created
      assert Map.has_key?(schedule, group_a.id)
      assert Map.has_key?(schedule, group_b.id)

      # Check that the correct number of lessons were scheduled for each group
      assert map_size(schedule[group_a.id]) == 5
      assert map_size(schedule[group_b.id]) == 4

      # Check for conflicts: no teacher should be in two places at the same time
      all_lessons =
        for {_group_id, group_schedule} <- schedule,
            {{day, order}, lesson} <- group_schedule do
          {lesson.teacher_id, day, order}
        end

      assert length(all_lessons) == 9
      assert length(Enum.uniq(all_lessons)) == 9
    end
  end

  # --- Funciones de Ayuda ---

  defp print_schedule(schedule) do
    # 1. Obtener datos para mapear IDs a nombres
    groups = Repo.all(Group) |> Map.new(&{&1.id, &1.name})
    subjects = Repo.all(Subject) |> Map.new(&{&1.id, &1.code})
    teachers = Repo.all(Teacher) |> Map.new(&{&1.id, String.split(&1.name)})
    config = Repo.get_by(SchoolConfig, [])
    time_slots = Repo.all(TimeSlot) |> Enum.sort_by(& &1.order)

    IO.puts("\n\n" <> String.duplicate("=", 80))
    IO.puts("=== HORARIO GENERADO ===")
    IO.puts(String.duplicate("=", 80))

    # 2. Iterar sobre cada grupo e imprimir su horario
    for {group_id, group_schedule} <- schedule do
      IO.puts("\n--- Grupo: #{groups[group_id]} ---")

      # Cabecera de la tabla
      header = ["Franja Horaria" | Enum.map(1..config.days, &"Día #{&1}")]
      IO.puts(format_row(header))
      IO.puts(String.duplicate("-", 125))

      # Filas con las clases
      for time_slot <- time_slots do
        row_data = ["#{time_slot.start_time}-#{time_slot.end_time}"]

        row_for_slot =
          for day <- 1..config.days do
            case group_schedule[{day, time_slot.order}] do
              %{subject_id: subject_id, teacher_id: teacher_id} ->
                "#{subjects[subject_id]} (#{teachers[teacher_id]})"

              nil ->
                "---"
            end
          end

        IO.puts(format_row(row_data ++ row_for_slot))
      end
    end

    IO.puts("\n" <> String.duplicate("=", 80) <> "\n")
  end

  defp format_row(items) do
    items
    |> Enum.map(&String.pad_trailing(to_string(&1), 20))
    |> Enum.join(" | ")
  end
end
