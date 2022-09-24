defmodule Request do
  @moduledoc """
  Parse and validate http request into [ok|false, path, params]


  """
  @doc """
  Receives a string in the form 'path?params' and returns '[:ok, path, params]' if valid
    or '[:error, request, ""] if invalid.
  For example, `/batches/1234/validate?path=file:/dir/name` returns [:ok, "batches/1234/validate", "path=file:/dir/name"]
  """
  def parse(request) do
     request
     |> strip_http
     |> split_path
     |> extract_params
  end

  @doc """
  Passed request and returns either {:ok, "path?params" } or { :error, message }
  """
  def strip_http(request) do
    case Regex.run(~r/GET (.*) HTTP/, request) do
      nil -> { :error, "Invalid HTTP request" }
      [_, match] -> { :ok, match }
    end
  end

  def split_path({ :error, message } = data), do: data
  def split_path({ _, request })  do
    request
    #|> String.trim_leading("/")
    |> String.split("?") #["batches/1234/validate","path=file:/dir/name"]
    |> prepend_status
    |> List.to_tuple
  end

  def extract_params({:error, _ } = data ), do: data
  def extract_params({:error, _, _ } = data ), do: data
  def extract_params({ _, path }), do: {:ok, path, %{} }
  def extract_params({_, path, params } = request ) do
    params
    |> String.split("&")
    |> to_keyword_list
    |> build_request(path)
  end

  defp build_request(params, path), do: {:ok, path, params }

  defp to_keyword_list(params) do
    Enum.map(params, fn(s) -> string_to_keyval(s) end)
  end

  def string_to_keyval(str) do
    String.split(str, "=")
    |> case do
         [key, val] -> { String.to_atom(key), val }
         [key] -> { String.to_atom(key), nil }
         _ -> {}
       end
  end

  defp prepend_status(request), do: [ :ok | request ]


end
