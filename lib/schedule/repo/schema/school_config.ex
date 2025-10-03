defmodule Schedule.Repo.Schema.SchoolConfig do
  use Ecto.Schema

  alias Schedule.Repo.Schema.TimeSlot

  import Ecto.Changeset

  schema "school_configs" do
    # número de días lectivos
    field :days, :integer
    # número de franjas por día
    field :slots_per_day, :integer

    has_many :time_slots, TimeSlot, on_delete: :delete_all

    timestamps()
  end

  def changeset(course, attrs) do
    course
    |> cast(attrs, [:days, :slots_per_day])
    |> cast_assoc(:time_slots, with: &TimeSlot.changeset/2)
    |> validate_required([:days, :slots_per_day])
  end
end
