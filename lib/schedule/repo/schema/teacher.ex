defmodule Schedule.Repo.Schema.Teacher do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment

  schema "teachers" do
    field :name, :string

    has_many :teacher_group_subject_assignments, TeacherGroupSubjectAssignment,
      on_delete: :delete_all

    has_many :subjects, through: [:teacher_group_subject_assignments, :subject]
    has_many :groups, through: [:teacher_group_subject_assignments, :group]

    # Campo virtual para el formulario
    field :assignments, {:array, :map}, virtual: true, default: []

    timestamps()
  end

  def changeset(teacher, attrs) do
    teacher
    |> cast(attrs, [:name, :assignments])
    |> validate_required([:name])
    |> process_assignments()
  end

  defp process_assignments(changeset) do
    case get_field(changeset, :assignments) do
      nil ->
        changeset

      assignments ->
        tgsa_changesets =
          for %{"subject_id" => subject_id, "group_ids" => group_ids} <- assignments,
              subject_id != "" and not is_nil(subject_id),
              group_id <- group_ids do
            %TeacherGroupSubjectAssignment{
              subject_id: maybe_parse_int(subject_id),
              group_id: maybe_parse_int(group_id)
            }
          end

        # Usamos put_assoc para que Ecto gestione las inserciones/borrados
        put_assoc(changeset, :teacher_group_subject_assignments, tgsa_changesets)
    end
  end

  defp maybe_parse_int(""), do: nil
  defp maybe_parse_int(nil), do: nil
  defp maybe_parse_int(value) when is_integer(value), do: value
  defp maybe_parse_int(value) when is_binary(value), do: String.to_integer(value)
end
