# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Schedule.Repo.insert!(%Schedule.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

import Ecto.Query, only: [from: 1]

alias Schedule.Repo
alias Schedule.Repo.Schema.Course
alias Schedule.Repo.Schema.Group
alias Schedule.Repo.Schema.Subject

# Clear existing data to make the seed script idempotent.
# Note: The order is important to respect foreign key constraints.
Repo.delete_all(from(g in Group))
Repo.delete_all(from(c in Course))
Repo.delete_all(from(s in Subject))

# Create subjects
subjects = [
  %{code: "MAT", name: "Matemáticas", is_core: true},
  %{code: "LCL", name: "Lengua Castellana y Literatura", is_core: true},
  %{code: "ING", name: "Inglés", is_core: true},
  %{code: "BIO", name: "Biología y Geología", is_core: true},
  %{code: "FIS", name: "Física y Química", is_core: true},
  %{code: "GEO", name: "Geografía e Historia", is_core: true},
  %{code: "MUS", name: "Música", is_core: false},
  %{code: "ART", name: "Educación Plástica, Visual y Audiovisual", is_core: false},
  %{code: "EF", name: "Educación Física", is_core: false},
  %{code: "TEC", name: "Tecnología y Digitalización", is_core: false},
  %{code: "VAL", name: "Valores Cívicos y Éticos", is_core: false},
  %{code: "REL", name: "Religión", is_core: false}
]

Enum.each(subjects, fn subject_attrs ->
  %Subject{}
  |> Subject.changeset(subject_attrs)
  |> Repo.insert!()
end)

IO.puts("✅ Created #{length(subjects)} subjects.")

# Create courses and their groups
courses_with_groups = [
  %{
    course: %{name: "1º ESO"},
    groups: [%{name: "A"}, %{name: "B"}, %{name: "C"}]
  },
  %{course: %{name: "2º ESO"}, groups: [%{name: "A"}, %{name: "B"}]},
  %{
    course: %{name: "3º ESO"},
    groups: [%{name: "A"}, %{name: "B"}, %{name: "C"}, %{name: "D"}]
  },
  %{course: %{name: "4º ESO"}, groups: [%{name: "A"}, %{name: "B"}]}
]

Enum.each(courses_with_groups, fn %{course: course_attrs, groups: groups_attrs} ->
  attrs = Map.put(course_attrs, :groups, groups_attrs)

  %Course{}
  |> Course.changeset(attrs)
  |> Repo.insert!()
end)

IO.puts("✅ Created #{length(courses_with_groups)} courses with their respective groups.")
