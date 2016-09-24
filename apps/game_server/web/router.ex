defmodule GameServer.Router do
  use GameServer.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", GameServer do
    pipe_through :api
  end
end
