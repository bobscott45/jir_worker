defmodule Parse do
  @moduledoc """
  Parse and validate http request into [ok|false, path, params]
  """

  def parse_request(request) do
    request
    |> split_path #[path, params]
    |> validate
  end
  def split_path(request) do
    #request = /batches/1234/validate?path=file:/dir/name
    request
    |> String.trim_leading("/")
    |> String.split("?")   #["batches/1234/validate","path=file:/dir/name"]
  end

  def validate([_]=request_parts), do: [ false, hd(request_parts), "" ]
  def validate( request_parts ) do
    request_parts
    |> validate_path
    |> validate_params
  end

  def validate_path([ path, _params ] = request_parts) do
    case Regex.run(~r/batches\/.\d*\/[a-z]*/, path) do
      :nil -> [ :false | request_parts ]
      _ -> [ :ok | request_parts ]
      end
  end

  def validate_params( [:error, _, _] = request_parts), do: request_parts
  def validate_params( [ _, path, params ] ) do
    case Regex.run(~r/path=[a-z]*:.*/, params) do
      :nil -> [ :error, path, params]
      _ -> [ :ok, path, params ]
    end
  end
#
end
