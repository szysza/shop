defmodule Shop.Store.ProductDiscountRuleTest do
  use Shop.DataCase
  alias Shop.Repo
  alias Shop.Store.ProductDiscountRule
  alias Shop.Store.Product
  alias Shop.Store.DiscountRule

  @valid_attrs %{product_id: 1, discount_rule_id: 1}
  @invalid_attrs %{}

  describe "valid changeset" do
    setup [:create_product, :create_discount_rule]

    test "creates an product discount rule", %{discount_rule: discount_rule, product: product} do
      attrs = %{@valid_attrs | product_id: product.id, discount_rule_id: discount_rule.id}
      changeset = ProductDiscountRule.changeset(%ProductDiscountRule{}, attrs)
      assert changeset.valid?
    end

    test "does not allow to create duplicated ProductDiscountRule for pair of product and order",
    %{discount_rule: discount_rule, product: product} do
      attrs = %{@valid_attrs | product_id: product.id, discount_rule_id: discount_rule.id}
      ProductDiscountRule.changeset(%ProductDiscountRule{}, attrs) |> Repo.insert()

      changeset = ProductDiscountRule.changeset(%ProductDiscountRule{}, attrs)

      assert {:error, changeset} = Repo.insert(changeset)
      assert match?(%{product_id: ["has already been taken"]}, errors_on(changeset))
    end
  end

  test "changeset is not valid when created with invalid attributes" do
    changeset = ProductDiscountRule.changeset(%ProductDiscountRule{}, @invalid_attrs)
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

  defp create_discount_rule(_context) do
    discount_rule =
      DiscountRule.changeset(%DiscountRule{}, %{
        min_quantity: 1,
        step: 1,
        apply_to_all: false,
        discount: 200
      })
      |> Repo.insert!()

    {:ok, discount_rule: discount_rule}
  end
end
