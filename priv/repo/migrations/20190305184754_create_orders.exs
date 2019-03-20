defmodule Shop.Repo.Migrations.CreateOrders do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :total, :integer

      timestamps()
    end
  end
end
