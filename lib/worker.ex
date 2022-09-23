defmodule Worker do
  @moduledoc """
  Listens for connection
  """

  def main do
    HttpListener.start()
  end
end
