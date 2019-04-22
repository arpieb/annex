defmodule Annex.AndTest do
  use ExUnit.Case
  alias Annex.Sequence

  @data [
    [1.0, 1.0, 1.0],
    [1.0, 0.0, 1.0],
    [0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0],
    [0.0, 0.0, 1.0],
    [0.0, 1.0, 0.0],
    [0.0, 1.0, 1.0]
  ]

  @labels [
    [1.0],
    [0.0],
    [0.0],
    [0.0],
    [0.0],
    [0.0],
    [0.0]
  ]

  test "and works" do
    assert {loss, %Sequence{} = seq} =
             Annex.sequence([
               Annex.dense(6, input_dims: 3),
               Annex.activation(:tanh),
               Annex.dense(6, input_dims: 6),
               Annex.activation(:tanh),
               Annex.dense(1, input_dims: 6),
               Annex.activation(:sigmoid)
             ])
             |> Annex.train(@data, @labels,
               learning_rate: 0.05,
               name: "and T or F",
               halt_condition: {:epochs, 100_000}
             )

    [should_be_true] = Annex.predict(seq, [1.0, 1.0, 1.0])
    [should_be_false] = Annex.predict(seq, [1.0, 0.0, 1.0])

    assert_in_delta(should_be_false, 0.0, 0.1)
    assert_in_delta(should_be_true, 1.0, 0.1)
  end
end