defmodule Schedule.Repo.Schema.TeacherAvailability do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Teacher

  schema "teacher_availability" do
    belongs_to :teacher, Teacher
    field :day_of_week, :integer
    field :slot_number, :integer

    timestamps()
  end

  def changeset(avail, attrs) do
    avail
    |> cast(attrs, [:teacher_id, :day_of_week, :slot_number])
    |> validate_required([:teacher_id, :day_of_week, :slot_number])
  end
end
