defmodule CodeCorps.CommentController do
  @analytics Application.get_env(:code_corps, :analytics)

  use CodeCorps.Web, :controller
  use JaResource

  alias CodeCorps.Comment

  plug :load_and_authorize_changeset, model: Comment, only: [:create]
  plug :load_and_authorize_resource, model: Comment, only: [:update]
  plug JaResource

  def handle_create(_conn, attributes) do
    Comment.create_changeset(%Comment{}, attributes)
  end
end
