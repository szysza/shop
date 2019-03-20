defmodule Shop.Store.ProductDiscountRule do
  use Ecto.Schema
  import Ecto.Changeset


  schema "product_discount_rules" do
    timestamps()

    belongs_to :product, Shop.Store.Product
    belongs_to :discount_rule, Shop.Store.ProductDiscountRule
  end

  @doc false
  def changeset(product_discount_rule, attrs \\ %{}) do
    product_discount_rule
    |> cast(attrs, [:product_id, :discount_rule_id])
    |> validate_required([:product_id, :discount_rule_id])
    |> unique_constraint(:product_id, name: :index_discounts_on_products)
  end
end
