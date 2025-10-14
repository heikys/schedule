defmodule Schedule.Repo.Schema.Teacher do
  use Ecto.Schema
  import Ecto.Changeset

  alias Schedule.Repo.Schema.TeacherGroupSubjectAssignment

  schema "teachers" do
    field :name, :string
    field :has_special_schedule, :boolean, default: false
    field :special_schedule_start_time, :time
    field :special_schedule_end_time, :time

    has_many :teacher_group_subject_assignments, TeacherGroupSubjectAssignment,
      on_delete: :delete_all

    has_many :subjects, through: [:teacher_group_subject_assignments, :subject]
    has_many :groups, through: [:teacher_group_subject_assignments, :group]

    # Campo virtual para el formulario
    field :assignments, {:array, :map}, virtual: true, default: []

    timestamps()
  end

  def changeset(teacher, attrs) do
    attrs = prepare_attrs(attrs)

    teacher
    |> cast(attrs, [:name, :assignments, :special_schedule_start_time, :special_schedule_end_time])
    |> cast(attrs, [:has_special_schedule], empty_values: [false])
    |> validate_required([:name])
    |> process_assignments()
  end

  defp prepare_attrs(attrs) do
    Enum.map(attrs, fn {k, v} -> {k, prepare_attr(k, v)} end) |> Enum.into(%{})
  end

  defp prepare_attr("has_special_schedule", "false"), do: false
  defp prepare_attr("has_special_schedule", value), do: value
  defp prepare_attr(_key, value), do: value

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
