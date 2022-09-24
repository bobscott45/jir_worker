defmodule HttpListener do
  @behaviour :ranch_protocol
  @timeout 5000
  @moduledoc """
  Listens for http requests on port 8877 and responds with { status, message }
  """
  def start() do
    :ranch.start_listener(:worker, :ranch_tcp,
      [port: 8877],
      HttpListener, [])
  end

  def start_link(ref, transport, opts) do
    {:ok, spawn_link(__MODULE__, :init, [ref, transport, opts])}
  end

  def init(ref, transport, _opts) do
    {:ok, socket} = :ranch.handshake(ref)
    get_request(socket, transport)
  end

  def get_request(socket, transport) do
    case transport.recv(socket, 0, @timeout) do
      {:ok, data} ->
        Request.parse(data)
        |> case do
        {:error, message} -> send_response(socket, transport, "422 Unprocessable Entity", message)
        request -> send_response(socket, transport, "200 OK", Route.run(request))
        end
        transport.close(socket)
    end
  end

  def send_response( socket, transport, status, content) do
    Response.send_header(socket, transport, status)
    Response.send_content(socket, transport, content)

  end




end



