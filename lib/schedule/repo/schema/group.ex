defmodule Schedule.Repo.Schema.Group do
  use Ecto.Schema

  # alias Schedule.Repo.Schema.Assigment
  alias Schedule.Repo.Schema.Course
  # alias Schedule.Repo.Schema.GroupSubject

  import Ecto.Changeset

  schema "groups" do
    field :name, :string
    belongs_to :course, Course
    # has_many :group_subjects, GroupSubject
    # has_many :assignments, Assignment

    timestamps()
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
