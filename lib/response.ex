defmodule Response do
  @moduledoc false
  def send_header(socket, transport, status) do
    transport.send(socket, "HTTP/1.1 #{status}\nContent-Type:text/html\nDate:#{now()}\nServer:ranch\n\n")
  end

  def send_content(socket, transport, content) do
    transport.send(socket, content)
  end

  def now() do
    DateTime.utc_now
    |> Calendar.strftime("%a, %-d %b %Y %X GMT")
  end

end
