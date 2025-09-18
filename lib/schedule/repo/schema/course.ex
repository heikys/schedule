defmodule Schedule.Repo.Schema.Course do
  use Ecto.Schema

  alias Schedule.Repo.Schema.Group

  import Ecto.Changeset

  schema "courses" do
    field :name, :string
    # número de días lectivos
    field :days, :integer
    # número de franjas por día
    field :slots_per_day, :integer
    has_many :groups, Group

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:name, :days, :slots_per_day])
    |> cast_assoc(:groups, with: &Group.changeset/2)
    |> validate_required([:name, :days, :slots_per_day])
  end
end
