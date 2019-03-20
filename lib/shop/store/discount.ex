defmodule Shop.Store.Discount do
  alias Shop.Store.DiscountRule
  alias Shop.Store.Item

  @doc """
    Calculates discount for given discount rule and item
  """
  def calculate(%DiscountRule{min_quantity: min_quantity}, %Item{quantity: quantity}) when quantity < min_quantity do
    0
  end

  @doc """
    Calculates discount for given discount rule and item
  """
  def calculate(%DiscountRule{discount: discount} = discount_rule, %Item{quantity: quantity}) do
    total_discount = number_of_items_to_discount(discount_rule, quantity) * discount
    trunc(total_discount)
  end

  defp number_of_items_to_discount(
         %DiscountRule{
           max_quantity: max_quantity,
           step: step,
           apply_to_all: true
         },
         quantity
       ) do
    if max_quantity do
      div(Enum.min([max_quantity, quantity]), step)
    else
      div(quantity, step)
    end
  end

  defp number_of_items_to_discount(
         %DiscountRule{
           min_quantity: min_quantity,
           max_quantity: max_quantity,
           step: step,
           apply_to_all: false
         },
         quantity
       ) do
    if max_quantity do
      div((max_quantity - min_quantity + step), step)
    else
      div((quantity - min_quantity + step), step)
    end
  end
end
