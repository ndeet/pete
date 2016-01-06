defmodule PetePhoenix.Router do
  use PetePhoenix.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PetePhoenix do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "gallery", GalleryController, only: [:index, :show]
  end

  # Other scopes may use custom stacks.
  # scope "/api", PetePhoenix do
  #   pipe_through :api
  # end
end
