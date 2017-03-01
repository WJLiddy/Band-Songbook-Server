class ClientConnection


  def initialize(user_name, socket, group_name, is_leader, all_groups) 
    @user = User.new(user_name,socket)
    user.songsocket.send_ok
    @group_name = group_name

    @leader = is_leader
    
    @all_groups = all_groups

    if(is_leader)
      @group =  Group.new(user)
      @all_groups[group_name] = group
    else
      @all_groups[group_name].add_member(user)
      @group =  @all_groups[group_name]
      @group.send_updated_group_info
    end
  end

  def abort_conn
    if(@leader)
      puts "Connection lost: Bandleader #{user.name}"
      # Close all of the sockets of the group members.
      @group.close
      # Delete the group.
      @all_groups.delete(@group_name)
    else
      puts "Connection lost: #{user.name}"  
      @group.delete_member(user)
    end
  end

  def start
   while true
      begin
        msg =  @user.songbooksocket.recv_json
     rescue  Errno::ECONNRESET
        #abort connection
        abort_conn
        return
      end

      if msg
        begin
          request = JSON.parse(msg)
        rescue JSON::ParserError => e
          @user.songbooksocket.send_error(socket, e.message)
          next
        end

        # MSG was ok.
        if(@leader)
          # C4
          if(request["request"] == "begin session" && request["songs"])
            @group.forward_songs(request["songs"])
          end
        end
      end
    end
  end
end