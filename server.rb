require_relative 'group'
require_relative 'user'
require 'json'
require 'socket'

class Server
  def initialize
    # TODO: In production. don't abort threads on exception, handle 'em
    Thread.abort_on_exception = true
    @all_groups = {}
  end

 
  def group_member_loop(user, socket, group_name)


    # Group members are passive. The only thing they can do is quit.
    # And if that happens, I remove them from the group.
    # What i do is read (which updates the socket state) and If i get an exception, I close.
    begin
    while true
      sleep 0.1
      socket.read
      if socket.closed?
        raise IOError
      end
    end
    rescue IOError

      return
    end

  end


  # If "test" is enabled, returns the sockets so they can be closed.
  def launch(test = false)
    if(test)
      #open two ports for the server to test multiple connections
      t1 = TCPServer.open(44106)
      t2 = TCPServer.open(44107)
      Thread.new{run_server(t1)}
      Thread.new{run_server(t2)}

      return [t1, t2]
    else
      run_server(TCPServer.open(44106))
    end
  end

  # we know the request user name, request, and group names are all valid.
  # return when we are done talking to the client, or the client crashed.
  def handle_request(socket, user_name, request. group_name)
    if request == "create group"
      if @groups[group_name]
        socket.send_error("Group name is already taken")
        return
      else
       # group name ok. start the server. This returns when the connection ends.
       ClientConnection.new(user, socket, group_name, true, @all_groups).start
     end
   else
      # we tried to join a group.
      if !@groups[group_name]
        socket.send_error("Group name does not exist")
        return
      else
       ClientConnection.new(user, socket, group_name, false, @all_groups).start
      end
    end
  end

  def run_server(server)
    begin
      loop do
        Thread.start(server.accept) do |socket|
          puts 'Connection Recieved.'

          songbook_socket = SongbookSocket.new(socket)
          # Await the first JSON packet to see what they want.

          begin
            request = songbook_socket.recv_json 
          rescue JSON::ParserError => e
            # they didn't send a valid json, just quit.
            songbook_socket.send_error(e.message)
            songbook_socket.close
            return
          end

          # Make sure the proper fields are there
          if(request.nil? || request['user name'].nil? || request['request'].nil? || request['group name'].nil? ))
            songbook_socket.send_error(socket, "JSON was well formed but missing username or request field")
            songbook_socket.close
            return
          end

          # We got a well formed request, so handle the connection. 
          # This function only returns when the session is over.
          handle_connection(songbook_socket, request['user name'], request['request'], request['group name'])

          puts 'Connection Terminated.'
          songbook_socket.close
        end
      end
    # Only called if server forcefully killed.
    rescue IOError => e
      puts "Server forcekilled"
    end
  end
end
