defmodule Schedule.Repo.Schema.SubjectTeacher do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher

  schema "subjects_teachers" do
    belongs_to :subject, Subject
    belongs_to :teacher, Teacher
  end

  def changeset(subject_teacher, attrs) do
    subject_teacher
    |> cast(attrs, [:subject_id, :teacher_id])
    |> validate_required([:subject_id, :teacher_id])
  end
end
