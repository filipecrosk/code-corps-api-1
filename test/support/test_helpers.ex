defmodule CodeCorps.TestHelpers do
  alias CodeCorps.Repo
  alias CodeCorps.User

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      email: "test@user.com",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      password: "password",
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!()
  end
end