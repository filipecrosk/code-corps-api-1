defmodule CodeCorps.UserController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  import CodeCorps.FilterHelpers, only: [id_filter: 2]

  alias CodeCorps.User
  alias JaSerializer.Params

  plug :load_and_authorize_resource, model: User, only: [:update]
  plug JaResource, except: [:update]

  def filter(_conn, query, "id", id_list) do
    query |> id_filter(id_list)
  end

  def handle_create(_conn, attributes) do
    User.registration_changeset(%User{}, attributes)
  end

  def update(conn, %{"id" => id, "data" => data = %{"type" => "user", "attributes" => _user_params}}) do
    changeset = User |> Repo.get!(id) |> User.update_changeset(Params.to_attributes(data))

    case Repo.update(changeset) do
      {:ok, user} ->
        conn
        |> @analytics.track(:updated_profile)
        |> render("show.json-api", data: user)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(CodeCorps.ChangesetView, "error.json-api", changeset: changeset)
    end
  end

  def email_available(conn, %{"email" => email}) do
    hash = User.check_email_availability(email)
    conn |> json(hash)
  end

  def username_available(conn, %{"username" => username}) do
    hash = User.check_username_availability(username)
    conn |> json(hash)
  end
end
