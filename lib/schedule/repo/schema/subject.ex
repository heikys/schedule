defmodule Schedule.Repo.Schema.Subject do
  use Ecto.Schema

  import Ecto.Changeset

  schema "subjects" do
    field :code, :string
    field :name, :string
    field :is_core, :boolean, default: true

    timestamps()
  end

  def changeset(subject, attrs) do
    subject
    |> cast(attrs, [:code, :name, :is_core])
    |> validate_required([:name, :code])
    |> unique_constraint(:code)
  end
end
