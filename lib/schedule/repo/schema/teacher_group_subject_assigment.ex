defmodule Schedule.Repo.Schema.TeacherGroupSubjectAssignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher

  schema "teacher_group_subject_assignment" do
    field :is_tutor, :boolean, default: false
    belongs_to :teacher, Teacher
    belongs_to :group, Group
    belongs_to :subject, Subject

    # Campo virtual para el formulario
    field :group_ids, {:array, :any}, virtual: true, default: []

    timestamps()
  end

  def changeset(assign, attrs) do
    assign
    |> cast(attrs, [:teacher_id, :group_id, :subject_id, :is_tutor])
    |> validate_required([:teacher_id, :group_id, :subject_id])
  end
end
