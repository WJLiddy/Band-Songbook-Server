require_relative 'group'
require_relative 'user'
require 'json'
require 'socket'
class Server
  def initialize
    # TODO: In production. don't abort threads on exception, handle 'em
    Thread.abort_on_exception = true
    @groups = {}
  end
  
  # blocks until it recieves a new line from the socket, and parses the json.
  # TODO error out otherwise.
  def recv_json(socket)
    JSON.parse(socket.gets)
  end

  def send_ok(socket)
     socket.puts ({"response" => "ok"}.to_json)
     socket.flush
  end

  def send_error(socket, message)
     socket.puts ({"response" => "error", "error message" => message}.to_json )
     socket.flush
  end

  def bandleader_loop(user, socket, group_name)
    group = Group.new(user)
    @groups[group_name] = group
    send_ok(socket)
    loop do
      # ...
    end
  end

  def group_member_loop(user, socket, group_name)
    group = @groups[group_name]
    group.members << group
    # Group members are passive. The only thing they can do is quit.
    # And if that happens, I remove them from the group.
    # Sleep will suffice for now
    loop { sleep 300 }
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

  def run_server(server)
    begin
      loop do
        Thread.start(server.accept) do |socket|
          puts 'Connection Recieved.'
          # Await the first JSON packet to tell what room they want to join,
          # or if they want to create.
          begin
            request = recv_json(socket)
          rescue JSON::ParserError => e
            send_error(socket, e.message)
            request = nil
          end

          # Make sure the proper fields are there
          if(!request.nil? && (request['user name'].nil? || request['request'].nil?))
            send_error(socket, "JSON was well formed but missing username or request field")
            request = nil
          end

          if(!request.nil?)
            # Create the user
            user = User.new(request['user name'], socket)
            # Create or join the group.
            bandleader_loop(user, socket, request['group name']) if request['request'] == 'create group'
            group_member_loop(user, socket, request['group name']) if request['request'] == 'join group'
          end
          puts 'Connection Terminated.'
          socket.close
        end
      end
    # Only called if server forcefully killed.
    rescue IOError => e
      #puts "#{e.message}"
    end
  end
end
