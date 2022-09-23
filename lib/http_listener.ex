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
        [_, match] = Regex.run(~r/GET (.*) HTTP/, data)
        match
        |> String.trim_leading("/")
        |> String.split("/")
        |> case do
          ["batches", id, operation] ->
            spawn(fn -> Batch.process_batch(id, operation) end)
            send_response(socket, transport, "200 OK", "{'status':'ok'}")
          _ ->
            send_response(socket, transport, "422 Unprocessable Entity", "{'status':'error', 'message':'invalid parameters'}")
        end
        transport.close(socket)
    end
  end

  def send_response(socket, transport, status, content) do
    header = "HTTP/1.1 #{status}\nContent-Type:text/html\nDate:#{now()}\nServer:ranch\nContent-Length:#{String.length(content)}\n\n"
    transport.send(socket, header)
    transport.send(socket, content)
  end

  def now() do
    DateTime.utc_now
    |> Calendar.strftime("%a, %-d %b %Y %X GMT")
  end


end



