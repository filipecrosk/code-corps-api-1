defmodule CodeCorps.OrganizationController do
  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Organization

  import CodeCorps.ControllerHelpers, only: [coalesce_id_string: 1]

  plug :load_and_authorize_resource, model: Organization, only: [:create, :update]
  plug JaResource

  def filter(_conn, query, "id", id_list) do
    ids = id_list |> coalesce_id_string
    query |> where([object], object.id in ^ids)
  end

  def handle_create(_conn, attributes) do
    Organization.create_changeset(%Organization{}, attributes)
  end
end
