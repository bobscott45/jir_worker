defmodule JirWorkerTest do
  use ExUnit.Case
  doctest JirWorker

  test "greets the world" do
    assert JirWorker.hello() == :world
  end
end
