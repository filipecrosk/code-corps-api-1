defmodule CodeCorps.UserCategoryController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserCategory

  plug :load_resource, model: UserCategory, only: [:show], preload: [:user, :category]
  plug :load_and_authorize_changeset, model: UserCategory, only: [:create]
  plug :load_and_authorize_resource, model: UserCategory, only: [:delete]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def create(conn, %{"data" => %{"type" => "user-category"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, user_category} ->
        conn
        |> @analytics.track(:added, user_category)
        |> put_status(:created)
        |> put_resp_header("location", user_category_path(conn, :show, user_category))
        |> render("show.json-api", data: user_category)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
