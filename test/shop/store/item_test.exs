defmodule Shop.Store.ItemTest do
  use Shop.DataCase
  alias Shop.Repo
  alias Shop.Store.Item
  alias Shop.Store.Product
  alias Shop.Store.Order

  @valid_attrs %{quantity: 1, product_id: 1, order_id: 1, total_discount: 0}
  @invalid_attrs %{}

  describe "valid changeset" do
    setup [:create_product, :create_order]
    test "creates an item", %{order: order, product: product} do
      attrs = %{@valid_attrs | product_id: product.id, order_id: order.id}
      changeset = Item.changeset(%Item{}, attrs)
      assert changeset.valid?
    end

    test "does not allow to create duplicated item for pair of product and order", %{order: order, product: product} do
      attrs = %{@valid_attrs | product_id: product.id, order_id: order.id}
      Item.changeset(%Item{}, attrs) |> Repo.insert

      changeset = Item.changeset(%Item{}, attrs)

      assert {:error, changeset} = Repo.insert(changeset)
      assert match?(%{product_id: ["has already been taken"]}, errors_on(changeset))
    end

    test "total discount is not required" do
      changeset = Item.changeset(%Item{}, Map.delete(@valid_attrs, :total_discount))
      assert changeset.valid?
    end
  end

  test "changeset is not valid when created with invalid attributes" do
    changeset = Item.changeset(%Item{}, @invalid_attrs)
    refute changeset.valid?
  end

  defp create_product(_context) do
    product =
      Product.changeset(%Product{}, %{
        "name" => "Tshirt",
        "description" => "Tshirt with cool logo",
        "price" => 2000
      })
      |> Repo.insert!()
    {:ok, product: product}
  end

  defp create_order(_context) do
    order =
      Order.changeset(%Order{}, %{total: 10})
      |> Repo.insert!()

    {:ok, order: order}
  end
end
