defmodule Shop.Store.OrderTest do
  use Shop.DataCase
  alias Shop.Store.Order

  @valid_attrs %{total: 200}
  @invalid_attrs %{}

  test "changeset is valid when valid arguments are passed" do
    changeset = Order.changeset(%Order{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset is not valid when created with invalid attributes" do
    changeset = Order.changeset(%Order{}, @invalid_attrs)
    refute changeset.valid?
  end
end
