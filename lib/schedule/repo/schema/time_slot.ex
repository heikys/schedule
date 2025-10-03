defmodule Schedule.Repo.Schema.TimeSlot do
  use Ecto.Schema

  alias Schedule.Repo.Schema.SchoolConfig

  import Ecto.Changeset

  schema "time_slots" do
    field :start_time, :time
    field :end_time, :time
    field :order, :integer
    belongs_to :school_config, SchoolConfig

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(time_slot, attrs) do
    time_slot
    |> cast(attrs, [:start_time, :end_time, :order])
    |> validate_required([:start_time, :end_time, :order])
  end
end
