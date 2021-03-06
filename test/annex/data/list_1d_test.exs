defmodule Annex.Data.List1DTest do
  alias Annex.{
    AnnexError,
    Data,
    Data.List1D
  }

  @data_5 [1.0, 2.0, 3.0, 4.0, 5.0]

  @data_6 [1.0, 1.0, 1.0, 2.0, 2.0, 2.0]

  @data_8 [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0]

  @data_2_by_3 [
    [1.0, 1.0, 1.0],
    [2.0, 2.0, 2.0]
  ]

  @casts [
    {@data_5, [5], [5]},
    {@data_6, [6], [6]},
    {@data_8, [8], [8]}
  ]

  use Annex.DataCase, type: List1D, data: @casts

  require List1D

  describe "is_list1D guard" do
    test "true for flat lists of floats" do
      assert List1D.is_list1D([1.0, 2.0, 3.0]) == true
    end
  end

  describe "cast/2" do
    test "handles 2D shape with a 1 as the rows" do
      data = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0]
      assert List1D.cast(data, [1, 6]) == data
    end

    test "handles 2D shape with a 1 as the columns" do
      data = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0]
      assert List1D.cast(data, [6, 1]) == data
    end

    test "given a 1D list and a 1D shape of the same size" do
      data = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0]
      assert length(data) == 6
      assert List1D.cast(data, [6]) == data
    end

    test "raises for the wrong sized data" do
      data = [1.0, 1.0, 1.0, 2.0, 2.0, 2.0]
      assert_raise(AnnexError, fn -> List1D.cast(data, [7]) end)
    end

    test "raises for nested lists" do
      assert_raise(FunctionClauseError, fn -> List1D.cast(@data_2_by_3, [6]) end)
    end
  end

  describe "to_flat_list/1" do
    test "can handle flat lists" do
      flat_list = [1.0, 2.0, 3.0]
      assert List1D.to_flat_list(flat_list) == flat_list
    end

    test "raises for nested lists" do
      assert_raise(FunctionClauseError, fn -> List1D.to_flat_list(@data_2_by_3) end)
    end
  end

  describe "shape/1" do
    test "is correct for flat lists" do
      assert List1D.shape(@data_5) == [5]
    end

    test "raises for nested lists" do
      assert_raise(FunctionClauseError, fn -> List1D.shape(@data_2_by_3) end)
    end
  end

  describe "is_type?/1" do
    test "is true for flat lists" do
      assert List1D.is_type?(@data_5) == true
    end

    test "is true for float containing flat lists" do
      assert List1D.is_type?(@data_5) == true
    end

    test "is false for non list of float containing types" do
      assert List1D.is_type?(:nope) == false
      assert List1D.is_type?([:nope]) == false
      assert List1D.is_type?([1]) == false
      assert List1D.is_type?([[1]]) == false
      assert List1D.is_type?(1) == false
      assert List1D.is_type?(1.0) == false
      assert List1D.is_type?("1.0") == false
      assert List1D.is_type?('1.0') == false
      assert List1D.is_type?(true) == false
      assert List1D.is_type?(false) == false
      assert List1D.is_type?(%URI{}) == false
      assert List1D.is_type?(%{}) == false
    end
  end

  describe "normalize/1" do
    test "normalizes a list" do
      assert List1D.normalize([0.1, 0.2, 0.3]) == [0.0, 0.5000000000000001, 1.0]
    end

    test "works for zeros" do
      assert List1D.normalize([0.0, 0.0]) == [1.0, 1.0]
    end
  end

  describe "proportions/1" do
    test "works for zeros" do
      assert List1D.proportions([0.0, 0.0]) == [0.0, 0.0]
    end

    test "sum is 1.0 (or close)" do
      assert [0.2, 0.16, 0.12] |> List1D.proportions() |> Enum.sum() == 1.0
    end

    test "produces expected vlaues" do
      assert List1D.proportions([0.1, 0.2, 0.3]) == [
               0.16666666666666666,
               0.3333333333333333,
               0.4999999999999999
             ]
    end
  end

  describe "transpose/1" do
    test "turns a 1D list into a transposed 2D list" do
      assert List1D.transpose([1.0, 2.0, 3.0]) == [
               [1.0],
               [2.0],
               [3.0]
             ]
    end
  end

  describe "Data Behaviour" do
    test "shape/1 works" do
      [{@data_5, [5]}, {@data_8, [8]}]
      |> Enum.each(fn {data, expected_shape} ->
        assert Data.shape(List1D, data) == expected_shape
      end)
    end

    test "cast/2 works" do
      [
        {@data_5, [5], @data_5},
        {@data_6, [6], @data_6},
        {@data_8, [8], @data_8}
      ]
      |> Enum.each(fn {data, shape_to_cast, expected} ->
        assert Data.cast(List1D, data, shape_to_cast) == expected
      end)
    end

    test "to_flat_list/1 works" do
      [
        {@data_5, @data_5},
        {@data_6, @data_6},
        {@data_8, @data_8}
      ]
      |> Enum.each(fn {data, expected} ->
        assert Data.to_flat_list(List1D, data) == expected
      end)
    end
  end
end
