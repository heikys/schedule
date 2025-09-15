defmodule Schedule.Repo.Schema.Classroom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "classrooms" do
    field :name, :string
    field :type, :string, default: "normal"
    field :capacity, :integer

    timestamps()
  end

  def changeset(classroom, attrs) do
    classroom
    |> cast(attrs, [:name, :type, :capacity])
    |> validate_required([:name])
  end
end
