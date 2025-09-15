defmodule Schedule.Repo.Schema.TeacherExtraHour do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Teacher

  schema "teacher_extra_hours" do
    belongs_to :teacher, Teacher
    field :day_of_week, :integer
    field :slot_number, :integer
    # "support" | "free"
    field :type, :string

    timestamps()
  end

  def changeset(extra_hour, attrs) do
    extra_hour
    |> cast(attrs, [:teacher_id, :day_of_week, :slot_number, :type])
    |> validate_required([:teacher_id, :day_of_week, :slot_number, :type])
  end
end
