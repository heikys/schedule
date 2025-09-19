defmodule Schedule.Repo.Schema.Subject do
  use Ecto.Schema

  alias Schedule.Repo.Schema.GroupSubject
  alias Schedule.Repo.Schema.GroupSubjectSplit
  alias Schedule.Repo.Schema.SubjectClassroomRequirement
  alias Schedule.Repo.Schema.SubjectTeacher
  alias Schedule.Repo.Schema.SubjectTimeConstraint
  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment

  import Ecto.Changeset

  schema "subjects" do
    field :code, :string
    field :name, :string
    field :is_core, :boolean, default: true
    has_many :subject_teachers, SubjectTeacher
    has_many :group_subjects, GroupSubject
    has_many :subject_classroom_requirements, SubjectClassroomRequirement
    has_many :teacher_group_subject_assignments, TeacherGroupSubjectAssignment
    has_many :group_subject_splits, GroupSubjectSplit
    has_many :subject_time_constraints, SubjectTimeConstraint

    timestamps()
  end

  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:code, :name, :is_core])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end
end
