defmodule CodeCorps.OrganizationMembershipController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.OrganizationMembership

  import CodeCorps.FilterHelpers, only: [id_filter: 2, organization_filter: 2, role_filter: 2]

  plug :load_resource, model: OrganizationMembership, only: [:show], preload: [:organization, :member]
  plug :load_and_authorize_resource, model: OrganizationMembership, only: [:delete]
  plug :load_and_authorize_changeset, model: OrganizationMembership, only: [:create, :update], preload: [:organization, :member]
  plug JaResource, except: [:create, :update]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def filter(_conn, query, "role", roles_list) do
    query |> role_filter(roles_list)
  end

  def handle_index(_conn, %{"organization_id" => organization_id}) do
    OrganizationMembership |> organization_filter(organization_id)
  end
  def handle_index(_conn, _params), do: OrganizationMembership

  def create(conn, %{"data" => %{"type" => "organization-membership"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, membership} ->
        conn
        |> @analytics.track(:created, membership)
        |> put_status(:created)
        |> put_resp_header("location", organization_membership_path(conn, :show, membership))
        |> render("show.json-api", data: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def update(conn, %{"id" => _id, "data" => %{"type" => "organization-membership", "attributes" => _params}}) do
    case Repo.update(conn.assigns.changeset) do
      {:ok, membership} ->
        render(conn, "show.json-api", data: membership)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
