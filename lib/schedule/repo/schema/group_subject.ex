defmodule Schedule.Repo.Schema.GroupSubject do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.Subject
  alias Schedule.Repo.Schema.Teacher

  schema "group_subjects" do
    belongs_to :group, Group
    belongs_to :subject, Subject
    belongs_to :teacher, Teacher

    field :hours_per_week, :integer
    field :slot_length, :integer, default: 1

    timestamps()
  end

  def changeset(group_subject, attrs) do
    group_subject
    |> cast(attrs, [:group_id, :subject_id, :teacher_id, :hours_per_week, :slot_length])
    |> validate_required([:group_id, :subject_id, :teacher_id, :hours_per_week])
  end
end
