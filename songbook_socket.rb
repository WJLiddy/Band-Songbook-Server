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
  # returns a valid hash if json was good.
  # returns nil if the server quites
  def recv_json
    # gets returns nil on the end-of-file condition
    begin

      msg = @socket.gets
      puts "\033[36m #{Time.new.inspect}: RECIEVED  #{msg} \033[39m";
      if msg
        parsed = JSON.parse(msg)
        return parsed
      else
        close
        return nil
      end
    rescue JSON::ParserError => e
      send_error(e.message)
      retry
    rescue  Errno::ETIMEDOUT
      puts "User timed out!"
      close
      return nil
    end
  end

  # send jsonstring to this socket.
  def send_json(jsonstring)
    puts "\033[32m #{Time.new.inspect} SENT #{jsonstring}  \033[39m";
    begin
     @socket.puts (jsonstring)
     @socket.flush
    rescue Errno::ECONNRESET, IOError, Errno::EPIPE, RuntimeError
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