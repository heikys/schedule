defmodule Schedule.Repo.Schema.SubjectClassroomRequirement do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.Subject

  schema "subject_classroom_requirements" do
    belongs_to :subject, Subject
    field :classroom_type, :string

    timestamps()
  end

  def changeset(req, attrs) do
    req
    |> cast(attrs, [:subject_id, :classroom_type])
    |> validate_required([:subject_id, :classroom_type])
  end
end
