defmodule Shop.Repo.Migrations.CreateProducts do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :name, :string
      add :description, :string
      add :price, :integer

      timestamps()
    end

    create unique_index(:products, [:name])
  end
end
