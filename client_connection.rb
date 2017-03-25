require_relative 'group'

Struct.new("User", :name, :songbook_socket) #=> Struct::Point

class ClientConnection

  def initialize(user_name, socket, group_name, is_leader, all_groups) 
    #inst. class vars
    @user = Struct::User.new(user_name,socket) 
    @user.songbook_socket.send_ok
    @group_name = group_name
    @leader = is_leader
    @all_groups = all_groups

    #do group operations
    if(is_leader)
      @group =  Group.new(@user)
      @all_groups[group_name] = @group
    else
      @all_groups[group_name].add_member(@user)
      @group =  @all_groups[group_name]
      @group.update_group_info
    end
  end

  def abort_conn
    if(@leader)
      puts "Connection lost: Bandleader #{@user.name}"
      # Close all of the sockets of the group members.
      @group.close
      # Delete the group.
      @all_groups.delete(@group_name)
    else
      puts "Connection lost: #{@user.name}"  
      @group.delete_member(@user)
      @group.update_group_info
    end
  end

  def start
   while true
      begin
        msg =  @user.songbook_socket.recv_json
     rescue  Errno::ECONNRESET, IOError
        #abort connection
        abort_conn
        return
      end

      if msg
        # MSG was ok.
        if(@leader)
          # C4
          if(msg["request"] == "begin session" && msg["songs"])
            @user.songbook_socket.send_ok
            @group.forward_songs(msg["songs"])
          end
          if(msg["request"] == "switch song" && msg["song id"])
            @user.songbook_socket.send_ok
            @group.switch_songs(msg["song id"])
          end
        else
          # not leader.
        end
      end
    end
  end
end