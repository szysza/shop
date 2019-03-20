defmodule ShopWeb.OrderControllerTest do
  use ShopWeb.ConnCase

  alias Shop.Store.Order
  alias Shop.Repo
  alias Shop.Store.Product

  describe "show/2" do
    setup [:create_order]

    test "show/2 renders show view when order is found", %{conn: conn, order: order} do
      conn = get(conn, Routes.order_path(conn, :show, order))
      assert html_response(conn, 200) =~ "Order"
    end
  end

  describe "create/2" do
    test "create/2 creates a new order and redirects to product path", %{conn: conn} do
      conn = post(conn, Routes.order_path(conn, :create, %{}))
      order = Shop.Store.find_order()
      assert order.total == 0
      assert redirected_to(conn) == Routes.product_path(conn, :index)
    end
  end

  describe "delete/2" do
    setup [:create_order]

    test "delete/2 removes an existing order and redirects to product path", %{
      conn: conn,
      order: order
    } do
      conn = delete(conn, Routes.order_path(conn, :delete, %Order{id: order.id}))
      order = Shop.Store.find_order()
      assert order == nil
      assert redirected_to(conn) == Routes.product_path(conn, :index)
    end
  end

  describe "add_product/2" do
    setup [:create_order, :create_product]

    test "add_product/2 adds a new item to the order and redirects order path", %{
      conn: conn,
      order: order,
      product: product
    } do
      conn = post(conn, Routes.order_path(conn, :add_product, order, product))
      order = Shop.Store.find_order()
      assert Enum.at(order.items, 0).quantity == 1
      assert redirected_to(conn) == Routes.order_path(conn, :show, order)
    end
  end

  describe "remove_product/2" do
    setup [:create_order, :create_product, :create_item]

    test "remove_product/2 removes an item from the order and redirects order path", %{
      conn: conn,
      order: order,
      product: product
    } do
      conn = post(conn, Routes.order_path(conn, :remove_product, order, product))
      order = Shop.Store.find_order()
      assert order.items == []
      assert redirected_to(conn) == Routes.order_path(conn, :show, order)
    end
  end

  defp create_order(_context) do
    {:ok, order} = Shop.Store.create_order()
    {:ok, order: order}
  end

  defp create_product(_context) do
    product =
      Product.changeset(%Product{}, %{
        name: "product",
        description: "awesome product",
        price: 500
      })
      |> Repo.insert!()

    {:ok, product: product}
  end

  defp create_item(%{order: order, product: product} = _context) do
    {:ok, _item} = Shop.Store.add_item_to_order(product.id, order.id)
    :ok
  end
end
