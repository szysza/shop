defmodule Shop.Store.Order do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "orders" do
    field :total, :integer

    timestamps()
    has_many :items, Shop.Store.Item, on_delete: :delete_all
  end

  @doc false
  def changeset(order, attrs \\ %{}) do
    order
    |> cast(attrs, [:total])
    |> validate_required([:total])
  end

  def total_of_items(query) do
    from o in query,
      join: i in assoc(o, :items),
      join: p in assoc(i, :product),
      select: %{total: coalesce(sum(p.price * i.quantity - i.total_discount), 0)}
  end

  def with_items(query) do
    from o in query,
      preload: [items: :product]
  end
end
