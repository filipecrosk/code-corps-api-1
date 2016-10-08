defmodule CodeCorps.FilterHelpers do
  use CodeCorps.Web, :model

  def id_filter(query, id_list) do
    ids = id_list |> coalesce_id_string
    query |> where([object], object.id in ^ids)
  end

  def limit_filter(query, count) do
    query |> limit(^count)
  end

  def number_as_id_filter(query, number) do
    query |> where([object], object.number == ^number)
  end

  def organization_filter(query, organization_id) do
    query |> where([object], object.organization_id == ^organization_id)
  end

  def project_filter(query, project_id) do
    query |> where([object], object.project_id == ^project_id)
  end

  def role_filter(query, roles_list) do
    roles = roles_list |> coalesce_string
    query |> where([object], object.role in ^roles)
  end

  def task_filter(query, task_id) do
    query |> where([object], object.task_id == ^task_id)
  end

  def task_status_filter(query, status) do
    query |> where([object], object.status == ^status)
  end

  def task_type_filter(query, task_type_list) do
    task_types = task_type_list |> coalesce_string
    query |> where([object], object.task_type in ^task_types)
  end

  def title_filter(query, title) do
    query |> where([object], ilike(object.title, ^"%#{title}%"))
  end

  defp coalesce_id_string(string) do
    string
    |> String.split(",")
    |> Enum.map(&String.to_integer(&1))
  end

  defp coalesce_string(string) do
    string
    |> String.split(",")
  end
end
