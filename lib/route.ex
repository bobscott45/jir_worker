defmodule Route do
  @moduledoc false
  def run({ :error, _, _ }), do: {:error}
  def run({_, path }), do: run({:ok, path, nil })
  def run({_, path, params }) do
    path
    |> action(params)
  end

  def split(path) do
    path
    |> String.trim_leading("/")
    |> String.split("/")
    |> List.to_tuple
  end

  def action(path, params) do
    case split(path) do
      { "batches", id, "validate" } ->
       "Validate batch #{id} data in #{params[:path]}"
      _ -> "Invalid route"
    end
  end
end
