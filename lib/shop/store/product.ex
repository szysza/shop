defmodule Shop.Store.Product do
  use Ecto.Schema
  import Ecto.Changeset

  schema "products" do
    field :description, :string
    field :name, :string
    field :price, :integer

    timestamps()

    has_many :product_discount_rules, Shop.Store.ProductDiscountRule
    has_many :discount_rules, through: [:product_discount_rules, :discount_rule]
  end

  @doc false
  def changeset(product, attrs \\ %{}) do
    product
    |> cast(attrs, [:name, :description, :price])
    |> validate_required([:name, :price])
    |> unique_constraint(:name)
  end
end
