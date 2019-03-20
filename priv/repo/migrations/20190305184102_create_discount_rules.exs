defmodule Shop.Repo.Migrations.CreateDiscountRules do
  use Ecto.Migration

  def change do
    create table(:discount_rules) do
      add :min_quantity, :integer, null: false
      add :max_quantity, :integer
      add :step, :integer, null: false
      add :apply_to_all, :boolean, default: false, null: false
      add :discount, :integer, null: false

      timestamps()
    end
  end
end
