defmodule CodeCorps.UserRoleController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserRole

  plug :load_resource, model: UserRole, only: [:show], preload: [:user, :role]
  plug :load_and_authorize_changeset, model: UserRole, only: [:create]
  plug :load_and_authorize_resource, model: UserRole, only: [:delete]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def create(conn, %{"data" => %{"type" => "user-role"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, user_role} ->
        conn
        |> @analytics.track(:added, user_role)
        |> put_status(:created)
        |> render("show.json-api", data: user_role)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
