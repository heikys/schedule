defmodule Schedule.Repo.Schema.GroupSubjectSplit do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Group
  alias Schedule.Repo.Schema.Subject

  schema "group_subject_splits" do
    belongs_to :group, Group
    belongs_to :subject, Subject

    field :split_count, :integer
    field :classroom_ids, {:array, :integer}, default: []

    timestamps()
  end

  def changeset(split, attrs) do
    split
    |> cast(attrs, [:group_id, :subject_id, :split_count, :classroom_ids])
    |> validate_required([:group_id, :subject_id, :split_count])
  end
end
