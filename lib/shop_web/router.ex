defmodule ShopWeb.Router do
  use ShopWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ShopWeb do
    pipe_through :browser

    get "/", ProductController, :index
    get "/products", ProductController, :index

    resources "/orders", OrderController, only: [:show, :create, :delete]
    post "/orders/:id/add_product/:product_id", OrderController, :add_product
    post "/orders/:id/remove_product/:product_id", OrderController, :remove_product
  end

  # Other scopes may use custom stacks.
  # scope "/api", ShopWeb do
  #   pipe_through :api
  # end
end
