# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Shop.Repo.insert!(%Shop.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Shop.Repo
alias Shop.Store.Product
alias Shop.Store.DiscountRule
alias Shop.Store.ProductDiscountRule

product_changesets = [
  Product.changeset(%Product{}, %{
    "name" => "Voucher",
    "description" => "Voucher for products from the store",
    "price" => 500
  }),
  Product.changeset(%Product{}, %{
    "name" => "Tshirt",
    "description" => "Tshirt with cool logo",
    "price" => 2000
  }),
  Product.changeset(%Product{}, %{
    "name" => "Mug",
    "description" => "Awsome mug for coffee",
    "price" => 750
  })
]

products =
  product_changesets
  |> Enum.map(fn product_changeset ->
    case Repo.insert_or_update(product_changeset) do
      {:ok, product} -> product
      {:error, _} -> nil
    end
  end)

two_for_one_discount_changeset =
  DiscountRule.changeset(%DiscountRule{}, %{
    "min_quantity" => 2,
    "step" => 2,
    "apply_to_all" => false,
    "discount" => 500
  })

buld_purchase_discount_changeset =
  DiscountRule.changeset(%DiscountRule{}, %{
    "min_quantity" => 3,
    "step" => 1,
    "apply_to_all" => true,
    "discount" => 100
  })

{:ok, two_for_one_discount} = Repo.insert_or_update(two_for_one_discount_changeset)
{:ok, bulk_purchase_discount} = Repo.insert_or_update(buld_purchase_discount_changeset)

product_dicount_rule_changesets = [
  ProductDiscountRule.changeset(%ProductDiscountRule{}, %{
    "product_id" => Enum.at(products, 0).id,
    "discount_rule_id" => two_for_one_discount.id
  }),
  ProductDiscountRule.changeset(%ProductDiscountRule{}, %{
    "product_id" => Enum.at(products, 1).id,
    "discount_rule_id" => bulk_purchase_discount.id
  })
]

Enum.map(product_dicount_rule_changesets, fn product_dicount_rule_changeset ->
  Repo.insert_or_update(product_dicount_rule_changeset)
end)
