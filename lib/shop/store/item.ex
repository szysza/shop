defmodule Shop.Store.Item do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "items" do
    field :quantity, :integer
    field :total_discount, :integer

    timestamps()

    belongs_to :order, Shop.Store.Order
    belongs_to :product, Shop.Store.Product
  end

  @doc false
  def changeset(item, attrs \\ %{}) do
    item
    |> cast(attrs, [:quantity, :product_id, :order_id, :total_discount])
    |> validate_required([:quantity, :product_id, :order_id])
    |> unique_constraint(:product_id, name: :index_products_on_orders)
  end

  def for_product(query, product_id) do
    from(i in query,
      where: i.product_id == ^product_id
    )
  end

  def for_order(query, order_id) do
    from(i in query,
      where: i.order_id == ^order_id
    )
  end
end
