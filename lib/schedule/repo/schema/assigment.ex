defmodule Schedule.Repo.Schema.Assignment do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Classroom
  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher

  schema "assignments" do
    belongs_to :group, Group
    belongs_to :subject, Subject
    belongs_to :teacher, Teacher
    belongs_to :classroom, Classroom

    field :day_of_week, :integer
    field :slot_number, :integer
    field :source, :string, default: "auto"

    timestamps()
  end

  def changeset(assign, attrs) do
    assign
    |> cast(attrs, [
      :group_id,
      :subject_id,
      :teacher_id,
      :classroom_id,
      :day_of_week,
      :slot_number,
      :source
    ])
    |> validate_required([
      :group_id,
      :subject_id,
      :teacher_id,
      :classroom_id,
      :day_of_week,
      :slot_number
    ])
  end
end
