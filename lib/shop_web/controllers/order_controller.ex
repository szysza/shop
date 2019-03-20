defmodule ShopWeb.OrderController do
  use ShopWeb, :controller

  def show(conn, %{"id" => id} = _params) do
    order = Shop.Store.find_order(id)
    order_total = Shop.Store.total_of_items_for_order(id)

    render(conn, "show.html", order: order, order_total: order_total)
  end

  def create(conn, _params) do
    Shop.Store.create_order

    conn
    |> put_flash(:info, "The order was created")
    |> redirect(to: Routes.product_path(conn, :index))
  end

  def delete(conn, %{"id" => id} = _params) do
    case Shop.Store.remove_order(id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "The order was deleted")
        |> redirect(to: Routes.product_path(conn, :index))
      {:error, _} ->
        conn
        |> put_flash(:error, "The order failed to be deleted")
        |> redirect(to: Routes.product_path(conn, :index))
    end
  end

  def add_product(conn, %{"product_id" => product_id, "id" => id} = _params) do
    order = Shop.Store.find_order(id)
    case Shop.Store.add_item_to_order(product_id, id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Product was added to order")
        |> redirect(to: Routes.order_path(conn, :show, order))
      {:error, _} ->
        conn
        |> put_flash(:info, "Product was not added")
        |> redirect(to: Routes.order_path(conn, :show, order))
    end
  end

  def remove_product(conn, %{"product_id" => product_id, "id" => id} = _params) do
    order = Shop.Store.find_order(id)
    case Shop.Store.remove_item_from_order(product_id, id) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Product was removed from order")
        |> redirect(to: Routes.order_path(conn, :show, order))
      {:error, _} ->
        conn
        |> put_flash(:info, "Product was not removed")
        |> redirect(to: Routes.order_path(conn, :show, order))
    end
  end
end
