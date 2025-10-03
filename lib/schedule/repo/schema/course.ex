defmodule Schedule.Repo.Schema.Course do
  use Ecto.Schema

  alias Schedule.Repo.Schema.Group

  import Ecto.Changeset

  schema "courses" do
    field :name, :string

    has_many :groups, Group

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name])
    |> cast_assoc(:groups, with: &Group.changeset/2)
    |> validate_required([:name])
  end
end
