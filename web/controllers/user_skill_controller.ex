defmodule CodeCorps.UserSkillController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.Helpers.Query, only: [id_filter: 2]

  alias CodeCorps.UserSkill

  plug :load_resource, model: UserSkill, only: [:show], preload: [:user, :skill]
  plug :load_and_authorize_changeset, model: UserSkill, only: [:create]
  plug :load_and_authorize_resource, model: UserSkill, only: [:delete]
  plug JaResource, except: [:create]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def create(conn, %{"data" => %{"type" => "user-skill"}}) do
    case Repo.insert(conn.assigns.changeset) do
      {:ok, user_skill} ->
        conn
        |> @analytics.track(:added, user_skill)
        |> put_status(:created)
        |> put_resp_header("location", user_skill_path(conn, :show, user_skill))
        |> render("show.json-api", data: user_skill)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end
end
