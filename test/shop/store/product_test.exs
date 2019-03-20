defmodule Shop.Store.ProductTest do
  use Shop.DataCase
  alias Shop.Repo
  alias Shop.Store.Product

  @valid_attrs %{name: "hat", price: 1000, description: "Description"}
  @invalid_attrs %{}

  test "changeset is not valid when created with invalid attributes" do
    changeset = Product.changeset(%Product{}, @invalid_attrs)

    refute changeset.valid?
  end

  test "description is not required" do
    changeset = Product.changeset(%Product{}, Map.delete(@valid_attrs, :description))
    assert changeset.valid?
  end

  test "changeset is valid when saved with valid attributes" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset is valid when product name is not unique" do
    changeset = Product.changeset(%Product{}, @valid_attrs)
    Repo.insert(changeset)
    changeset = Product.changeset(%Product{}, @valid_attrs)

    assert {:error, changeset} = Repo.insert(changeset)
    assert match?(%{name: ["has already been taken"]}, errors_on(changeset))
  end
end
