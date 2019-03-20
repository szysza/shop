defmodule Shop.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :quantity, :integer, null: false
      add :product_id, references(:products, on_delete: :nothing)
      add :order_id, references(:orders, on_delete: :delete_all)
      add :total_discount, :integer, null: false

      timestamps()
    end

    create index(:items, [:product_id])
    create index(:items, [:order_id])

    create unique_index(:items, [:product_id, :order_id], name: :index_products_on_orders)
  end
end
