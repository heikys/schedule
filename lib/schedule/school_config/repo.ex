defmodule Schedule.SchoolConfig.Repo do
  alias Schedule.Repo
  alias Schedule.Repo.Schema.SchoolConfig

  def list_school_configs do
    Repo.all(SchoolConfig)
  end

  def get_school_config!(id),
    do: Repo.get!(SchoolConfig, id) |> Repo.preload(:time_slots)

  def create_school_config(attrs \\ %{}) do
    %SchoolConfig{}
    |> SchoolConfig.changeset(attrs)
    |> Repo.insert()
  end

  def update_school_config(%SchoolConfig{} = school_config, attrs) do
    school_config
    |> SchoolConfig.changeset(attrs)
    |> Repo.update()
  end

  def delete_school_config(%SchoolConfig{} = school_config) do
    Repo.delete(school_config)
  end

  def change_school_config(%SchoolConfig{} = school_config, attrs \\ %{}) do
    SchoolConfig.changeset(school_config, attrs)
  end
end
