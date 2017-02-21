require_relative 'group'
require_relative 'user'
require 'json'
require 'socket'
class Server
  def initialize
    # TODO: don't abort threads on exception, handle 'em
    Thread.abort_on_exception = true
    @groups = {}
  end
  
  # blocks until it recieves a new line from the socket, and parses the json.
  # TODO error out otherwise.
  def recv_json(socket)
    JSON.parse(socket.gets)
  end

  def bandleader_loop(user, socket)
    group = Group.new(user)
    groups[request['group name']] = group
    loop do
      # ...
    end
  end

  def group_member_loop(user, socket)
    group = groups[request['group name']]
    group.members << group
    # Group members are passive. The only thing they can do is quit.
    # And if that happens, I remove them from the group.
    # Sleep will suffice for now
    loop { sleep 300 }
  end

  def launch
    server = TCPServer.open(44106)
    loop do
      Thread.start(server.accept) do |socket|
        puts 'Connection Recieved.'
        # Await the first JSON packet to tell what room they want to join,
        # or if they want to create.
        request = recv_json(socket)
        # Create the user
        user = User.new(request['user name'], socket)
        # Create or join the group.
        bandleader_loop(user, socket) if request['request'] == 'create group'
        group_member_loop(user, socket) if request['request'] == 'join group'
      end
    end
  end
end