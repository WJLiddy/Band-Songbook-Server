require 'socket'

# Small Socket class that sits on top of Ruby's socket API and provides some helpers
class SongbookSocket
  attr_reader :closed
  # Pass in an open socket
  def initialize(socket)
    @socket = socket
    @closed = false
  end

  # blocks until it recieves a new line from the client, and parses the json.
  # throws error if json not well formed.
  def recv_json
    # gets returns nil on the end-of-file condition
    msg = @socket.gets
    if msg
      return JSON.parse(msg)
    else
      close
      return nil
    end
  end

  # send jsonstring to this socket.
  def send_json(jsonstring)
    begin
     @socket.puts (jsonstring)
     @socket.flush
    rescue Errno::ECONNRESET, IOError, Errno::EPIPE
      close
    end
  end

  def send_ok
    send_json({"response" => "ok"}.to_json)
  end

  def send_error(message)
    send_json({"response" => "error", "error message" => message}.to_json)
  end

  def close
    @socket.close
    @closed = true
  end

end