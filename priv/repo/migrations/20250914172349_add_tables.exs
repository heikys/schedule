defmodule Schedule.Repo.Migrations.AddTables do
  use Ecto.Migration

  def change do
    # Cursos
    create table(:courses) do
      add :name, :string, null: false
      add :days, :integer, null: false, default: 5
      add :slots_per_day, :integer, null: false, default: 5
      timestamps()
    end

    # Grupos
    create table(:groups) do
      add :course_id, references(:courses, on_delete: :delete_all), null: false
      add :name, :string, null: false
      timestamps()
    end

    # Profesores
    create table(:teachers) do
      add :name, :string, null: false
      timestamps()
    end

    # Asignaturas
    create table(:subjects) do
      add :code, :string
      add :name, :string, null: false
      add :is_core, :boolean, default: true
      timestamps()
    end

    # Relación asignaturas - profesores
    create table(:subjects_teachers) do
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :teacher_id, references(:teachers, on_delete: :delete_all), null: false
    end

    # Horas por semana y bloques
    create table(:group_subjects) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :teacher_id, references(:teachers), null: false
      add :hours_per_week, :integer, null: false
      add :slot_length, :integer, default: 1
      timestamps()
    end

    # Aulas
    create table(:classrooms) do
      add :name, :string, null: false
      add :type, :string, default: "normal"
      add :capacity, :integer
      timestamps()
    end

    # Requisitos de aula por asignatura
    create table(:subject_classroom_requirements) do
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :classroom_type, :string, null: false
      timestamps()
    end

    # Franjas horarias
    create table(:time_slots) do
      add :day_of_week, :integer, null: false
      add :slot_number, :integer, null: false
      add :start_time, :time
      add :end_time, :time
      timestamps()
    end

    # Asignaciones finales (solver + edición manual)
    create table(:assignments) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :teacher_id, references(:teachers), null: false
      add :classroom_id, references(:classrooms), null: false
      add :day_of_week, :integer, null: false
      add :slot_number, :integer, null: false
      add :source, :string, default: "auto"
      timestamps()
    end

    # Disponibilidad de profesores
    create table(:teacher_availability) do
      add :teacher_id, references(:teachers, on_delete: :delete_all), null: false
      add :day_of_week, :integer, null: false
      add :slot_number, :integer, null: false
      timestamps()
    end

    # Restricciones de tiempo específicas para asignaturas/grupos
    create table(:subject_time_constraints) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :allowed_days, {:array, :integer}, default: []
      add :allowed_slots, {:array, :integer}, default: []
      add :required_slots, {:array, :integer}, default: []
      timestamps()
    end

    # Asignación manual de profesor a grupos para cada asignatura
    create table(:teacher_group_subject_assignment) do
      add :teacher_id, references(:teachers, on_delete: :delete_all), null: false
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      timestamps()
    end

    # Desdobles (splits de grupos)
    create table(:group_subject_splits) do
      add :group_id, references(:groups, on_delete: :delete_all), null: false
      add :subject_id, references(:subjects, on_delete: :delete_all), null: false
      add :split_count, :integer, null: false
      add :classroom_ids, {:array, :integer}, default: []
      timestamps()
    end

    # Horas de apoyo / libres
    create table(:teacher_extra_hours) do
      add :teacher_id, references(:teachers, on_delete: :delete_all), null: false
      add :day_of_week, :integer, null: false
      add :slot_number, :integer, null: false
      # "support" | "free"
      add :type, :string, null: false
      timestamps()
    end
  end
end
