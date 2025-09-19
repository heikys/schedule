defmodule Schedule.Repo.Schema.Teacher do
  use Ecto.Schema

  alias Schedule.Repo.Schema.Assignment
  alias Schedule.Repo.Schema.GroupSubject
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.TeacherAvailability
  alias Schedule.Repo.Schema.TeacherExtraHour
  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment

  import Ecto.Changeset

  schema "teachers" do
    field :name, :string

    many_to_many :subjects, Subject, join_through: "subjects_teachers"
    has_many :group_subjects, GroupSubject
    has_many :assignments, Assignment
    has_many :teacher_availability, TeacherAvailability
    has_many :teacher_group_subject_assignments, TeacherGroupSubjectAssignment
    has_many :teacher_extra_hours, TeacherExtraHour

    timestamps()
  end

  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> cast_assoc(:subjects)
  end
end
