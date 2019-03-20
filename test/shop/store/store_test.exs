defmodule Shop.StoreTest do
  use ExUnit.Case
  alias Shop.Repo
  alias Shop.Store.Product
  alias Shop.Store.Order
  alias Shop.Store.Item
  alias Shop.Store.DiscountRule
  alias Shop.Store.ProductDiscountRule

  setup do
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo)
    Ecto.Adapters.SQL.Sandbox.mode(Repo, {:shared, self()})
  end

  describe "Listing all of the products" do
    setup [:create_voucher]

    test "returns all products", %{voucher: voucher} do
      assert Shop.Store.list_products() == [voucher]
    end
  end

  describe "Creating an order when no order exists" do
    test "creates an new order when an order does not exist" do
      assert {:ok, order} = Shop.Store.create_order()
      assert order.total == 0
    end
  end

  describe "Creating an order when an order already exists" do
    setup [:create_order]

    test "returns the existing order when order is created", %{order: order} do
      assert {:ok, new_order} = Shop.Store.create_order()
      assert new_order == order
    end
  end

  describe "Removing an existing order" do
    setup [:create_order]

    test "deletes the existing order", %{order: %Order{id: id} = _order} do
      {:ok, deleted_order} = Shop.Store.remove_order(id)
      assert deleted_order.id == id
    end
  end

  describe "Removing an not existing order" do
    test "raises an error" do
      assert_raise Ecto.NoResultsError, fn -> Shop.Store.remove_order(1) end
    end
  end

  describe "Adding a new item to order" do
    setup [:create_order, :create_voucher, :create_voucher_discount]

    test "creates a new item within the order and applies discount", %{
      voucher: voucher,
      order: order
    } do
      {:ok, item} = Shop.Store.add_item_to_order(voucher.id, order.id)
      assert item.quantity == 1
      assert item.total_discount == 200
    end
  end

  describe "Adding an existing item to an order" do
    setup [:create_order, :create_voucher, :create_voucher_discount, :create_voucher_item]

    test "updates the quantity of the item and applies discount", %{
      voucher: voucher,
      order: order
    } do
      {:ok, item} = Shop.Store.add_item_to_order(voucher.id, order.id)
      assert item.quantity == 2
      assert item.total_discount == 400
    end
  end

  describe "Removing an item when quantity is greater than 1" do
    setup [:create_order, :create_voucher, :create_voucher_discount, :create_voucher_item]

    test "reduces the quantity of the item and reduces discount", %{
      voucher: voucher,
      order: order,
      voucher_item: voucher_item
    } do
      Item.changeset(voucher_item, %{quantity: 2, total_discount: 400}) |> Repo.update()

      {:ok, item} = Shop.Store.remove_item_from_order(voucher.id, order.id)
      assert item.quantity == 1
      assert item.total_discount == 200
    end
  end

  describe "Removing an item when quantity is equal to 1" do
    setup [:create_order, :create_voucher, :create_voucher_discount, :create_voucher_item]

    test "removes the item", %{voucher: voucher, order: order} do
      {:ok, item} = Shop.Store.remove_item_from_order(voucher.id, order.id)
      assert Repo.get(Item, item.id) == nil
    end
  end

  describe "Removing an not existing item" do
    setup [:create_order]

    test "removes the item", %{order: order} do
      {:ok, item} = Shop.Store.remove_item_from_order(1, order.id)
      assert item == nil
    end
  end

  describe "Calculating total of items for order" do
    setup [
      :create_order,
      :create_voucher,
      :create_voucher_discount,
      :create_voucher_item,
      :create_tshirt,
      :create_tshirt_discount,
      :create_tshirt_item
    ]

    test "returns total amount for order", %{order: order, voucher_item: voucher_item} do
      Item.changeset(voucher_item, %{quantity: 2, total_discount: 400}) |> Repo.update()

      assert Shop.Store.total_of_items_for_order(order.id) == 4800
    end
  end

  describe "Calculating total of items when there are no items within the order" do
    setup [:create_order]

    test "returns zero", %{order: order} do
      assert Shop.Store.total_of_items_for_order(order.id) == 0
    end
  end

  describe "Calculating total of items for not existing order" do
    test "returns zero" do
      assert Shop.Store.total_of_items_for_order(1) == 0
    end
  end

  defp create_voucher(_context) do
    voucher =
      Product.changeset(%Product{}, %{
        name: "Voucher",
        description: "Voucher for products from the store",
        price: 500
      })
      |> Repo.insert!()

    {:ok, voucher: voucher}
  end

  defp create_voucher_discount(%{voucher: voucher} = _context) do
    discount_rule =
      DiscountRule.changeset(%DiscountRule{}, %{
        min_quantity: 1,
        step: 1,
        apply_to_all: false,
        discount: 200
      })
      |> Repo.insert!()

    ProductDiscountRule.changeset(%ProductDiscountRule{}, %{
      product_id: voucher.id,
      discount_rule_id: discount_rule.id
    })
    |> Repo.insert!()

    :ok
  end

  defp create_voucher_item(%{voucher: voucher, order: order = _context}) do
    item =
      Item.changeset(%Item{}, %{
        quantity: 1,
        product_id: voucher.id,
        order_id: order.id,
        total_discount: 200
      })
      |> Repo.insert!()

    {:ok, voucher_item: item}
  end

  defp create_tshirt(_context) do
    tshirt =
      Product.changeset(%Product{}, %{
        name: "Tshirt",
        description: "Tshirt with cool logo",
        price: 2000
      })
      |> Repo.insert!()

    {:ok, tshirt: tshirt}
  end

  defp create_tshirt_discount(%{tshirt: tshirt} = _context) do
    discount_rule =
      DiscountRule.changeset(%DiscountRule{}, %{
        min_quantity: 1,
        step: 1,
        apply_to_all: true,
        discount: 600
      })
      |> Repo.insert!()

    ProductDiscountRule.changeset(%ProductDiscountRule{}, %{
      product_id: tshirt.id,
      discount_rule_id: discount_rule.id
    })
    |> Repo.insert!()

    :ok
  end

  defp create_tshirt_item(%{tshirt: tshirt, order: order = _context}) do
    item =
      Item.changeset(%Item{}, %{
        quantity: 3,
        product_id: tshirt.id,
        order_id: order.id,
        total_discount: 1800
      })
      |> Repo.insert!()

    {:ok, tshirt_item: item}
  end

  defp create_order(_context) do
    order =
      Order.changeset(%Order{}, %{total: 10})
      |> Repo.insert!()

    {:ok, order: order}
  end
end
