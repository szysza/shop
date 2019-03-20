defmodule Shop.Store.DiscountRuleTest do
  use Shop.DataCase
  alias Shop.Store.DiscountRule

  @valid_attrs %{min_quantity: 1, max_quantity: 5, step: 1, apply_to_all: false, discount: 200}
  @invalid_attrs %{}

  test "changeset is valid when valid arguments are passed" do
    changeset = DiscountRule.changeset(%DiscountRule{}, @valid_attrs)
    assert changeset.valid?
  end

  test "max quantity is not required" do
    changeset = DiscountRule.changeset(%DiscountRule{}, Map.delete(@valid_attrs, :max_quantity))
    assert changeset.valid?
  end

  test "changeset is not valid when created with invalid attributes" do
    changeset = DiscountRule.changeset(%DiscountRule{}, @invalid_attrs)
    refute changeset.valid?
  end
end
