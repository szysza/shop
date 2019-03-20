defmodule Shop.Repo.Migrations.CreateProductDiscountRules do
  use Ecto.Migration

  def change do
    create table(:product_discount_rules) do
      add :product_id, references(:products, on_delete: :nothing)
      add :discount_rule_id, references(:discount_rules, on_delete: :nothing)

      timestamps()
    end

    create index(:product_discount_rules, [:product_id])
    create index(:product_discount_rules, [:discount_rule_id])

    create unique_index(:product_discount_rules, [:product_id, :discount_rule_id], name: :index_discounts_on_products)
  end
end
