defmodule Shop.Store.DiscountRule do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "discount_rules" do
    field :apply_to_all, :boolean, default: false
    field :max_quantity, :integer
    field :min_quantity, :integer
    field :step, :integer
    field :discount, :integer

    timestamps()

    has_many :product_discount_rules, Shop.Store.ProductDiscountRule
  end

  @doc false
  def changeset(discount_rule, attrs \\ %{}) do
    discount_rule
    |> cast(attrs, [:min_quantity, :max_quantity, :step, :apply_to_all, :discount])
    |> validate_required([:min_quantity, :step, :apply_to_all, :discount])
  end

  def for_product(query, product_id) do
    from dr in query,
      join: pdr in assoc(dr, :product_discount_rules),
      where: pdr.product_id == ^product_id
  end

  def with_min_quantity_greater_or_equal_to(query, quantity) do
    from dr in query,
      where: dr.min_quantity <= ^quantity
  end
end
