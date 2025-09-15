defmodule Schedule.Repo.Schema.SubjectTimeConstraint do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.Subject

  schema "subject_time_constraints" do
    belongs_to :group, Group
    belongs_to :subject, Subject

    field :allowed_days, {:array, :integer}, default: []
    field :allowed_slots, {:array, :integer}, default: []
    field :required_slots, {:array, :integer}, default: []

    timestamps()
  end

  def changeset(constraint, attrs) do
    constraint
    |> cast(attrs, [:group_id, :subject_id, :allowed_days, :allowed_slots, :required_slots])
    |> validate_required([:group_id, :subject_id])
  end
end
