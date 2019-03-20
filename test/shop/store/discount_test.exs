defmodule Shop.Store.DiscountTest do
  alias Shop.Store.DiscountRule
  alias Shop.Store.Item
  use ExUnit.Case

  test "returns 0 when discount is not meant" do
    discount_rule = %DiscountRule{
      discount: 200,
      step: 1,
      min_quantity: 2,
      max_quantity: 3,
      apply_to_all: true
    }
    item = %Item{quantity: 1}

    assert Shop.Store.Discount.calculate(discount_rule, item) == 0
  end

  describe "when discount is limited to a number of items" do
    test "returns proper discount when discount is applied to all items during bulk purchase" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 1,
        min_quantity: 2,
        max_quantity: 3,
        apply_to_all: true
      }
      item = %Item{quantity: 3}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 600
    end

    test "returns proper discount when more items were purchased during bulk purchase then the discount applies to" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 1,
        min_quantity: 2,
        max_quantity: 3,
        apply_to_all: true
      }
      item = %Item{quantity: 4}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 600
    end

    test "returns proper discount when discount is applied to items above specified number during bulk purchase" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 1,
        min_quantity: 2,
        max_quantity: 3,
        apply_to_all: false
      }
      item = %Item{quantity: 4}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 400
    end

    test "returns proper discount when discount is applied to every n-th element" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 2,
        min_quantity: 2,
        max_quantity: 4,
        apply_to_all: false
      }
      item = %Item{quantity: 6}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 400
    end
  end

  describe "when there is no limit for max quantity" do
    test "returns proper discount when discount is applied to all items during bulk purchase" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 1,
        min_quantity: 2,
        max_quantity: nil,
        apply_to_all: true
      }
      item = %Item{quantity: 3}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 600
    end

    test "returnsqweqwewqe proper discount when discount is applied to all items during bulk purchase" do
      discount_rule = %DiscountRule{
        discount: 500,
        step: 2,
        min_quantity: 2,
        max_quantity: nil,
        apply_to_all: false
      }
      item = %Item{quantity: 3}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 500
    end

    test "returns proper discount when discount is applied to items above specified number during bulk purchase" do
      discount_rule = %DiscountRule{
        discount: 200,
        step: 1,
        min_quantity: 2,
        max_quantity: nil,
        apply_to_all: false
      }
      item = %Item{quantity: 3}

      assert Shop.Store.Discount.calculate(discount_rule, item) == 400
    end
  end
end
