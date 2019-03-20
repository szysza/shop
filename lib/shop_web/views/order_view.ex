defmodule ShopWeb.OrderView do
  use ShopWeb, :view

  def display_amount(amount) do
    "#{:erlang.float_to_binary(amount/100, [decimals: 2])}€"
  end
end
