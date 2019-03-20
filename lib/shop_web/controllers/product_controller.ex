defmodule ShopWeb.ProductController do
  use ShopWeb, :controller

  def index(conn, _params) do
    products = Shop.Store.list_products
    order    = Shop.Store.find_order

    render(conn, "index.html", products: products, order: order)
  end
end
