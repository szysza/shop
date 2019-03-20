defmodule Shop.Store do
  alias Shop.Repo
  alias Shop.Store.Product
  alias Shop.Store.Item
  alias Shop.Store.Order
  alias Shop.Store.DiscountRule

  @doc """
    Returns list of products
  """
  @spec list_products :: [%Product{}]
  def list_products do
    Product |> Repo.all
  end

  def find_order(order_id) do
    Order |> Order.with_items() |> Repo.get!(order_id)
  end

  def find_order() do
    Order |> Order.with_items() |> Repo.one
  end

  @doc """
    Creates an order or returns the last created one.
  """
  # In a more advanced version of the system this should accept currently logged in user id
  @spec create_order :: [%Order{}]
  def create_order do
    case Repo.one(Order) do
      nil ->
        Order.changeset(%Order{}, %{total: 0})
        |> Repo.insert
      order -> {:ok, order}
    end
  end

  @doc """
    Removes order with all of the items
  """
  @spec create_order :: [%Order{}]
  def remove_order(order_id) do
    order = Repo.get!(Order, order_id)
    Repo.delete order
  end

  @doc """
    Adds a new item to the order or increases it's quantity
  """
  @spec add_item_to_order(integer, integer) :: {:ok, %Item{}} | {:error, String.t}
  def add_item_to_order(product_id, order_id) do
    item = find_item(product_id, order_id)

    add_item(item, product_id, order_id)
    |> apply_discounts(product_id)
  end

  defp add_item(nil, product_id, order_id) do
    product = Repo.get(Product, product_id)

    %Item{}
    |> Item.changeset(%{product_id: product_id, order_id: order_id, quantity: 1, product_amount: product.price})
    |> Repo.insert
  end

  defp add_item(item, _product_id, _order_id) do
    Item.changeset(item, %{quantity: item.quantity + 1})
    |> Repo.update
  end

  @doc """
    Reduces the quantity of item or removes the item completely from the order
  """
  @spec remove_item_from_order(integer, integer) :: {:ok, %Item{}} | {:error, String.t}
  def remove_item_from_order(product_id, order_id) do
    item = find_item(product_id, order_id)

    remove_item(item)
    |> apply_discounts(product_id)
  end

  defp find_item(product_id, order_id) do
    Item |> Item.for_product(product_id) |> Item.for_order(order_id) |> Repo.one
  end

  defp remove_item(nil), do: {:ok, nil}

  defp remove_item(%Item{quantity: quantity} = item) when quantity <= 1, do: Repo.delete(item)

  defp remove_item(%Item{quantity: quantity} = item) when quantity > 1 do
    Item.changeset(item, %{quantity: item.quantity - 1})
    |> Repo.update
  end

  defp apply_discounts({:ok, nil} = item_response, _product_id), do: item_response

  defp apply_discounts({:ok, item} = _item_response, product_id) do
    discount_rules = DiscountRule |> DiscountRule.for_product(product_id) |> DiscountRule.with_min_quantity_greater_or_equal_to(item.quantity) |> Repo.all
    discount = Enum.reduce(discount_rules, 0, fn discount_rule, acc -> acc + Shop.Store.Discount.calculate(discount_rule, item) end)

    Item.changeset(item, %{total_discount: discount})
    |> Repo.update
  end

  defp apply_discounts({:error, _message} = item_response, _product_id) do
    item_response
  end

  @doc """
    Returns total of items for given order
  """
  @spec total_of_items_for_order(integer) :: integer
  def total_of_items_for_order(order_id) do
    order = Order |> Order.total_of_items |> Repo.get(order_id)

    case order do
      nil -> 0
      o -> o.total
    end
  end
end
