  # define user struct

# Just holds the names and sockets for all the users, and provides some group methods to address the entire group
class Group
  def initialize(leader)
    @leader = leader
    @members = []
  end

  # some helpers
  def leader_songsocket
    return @leader.songsocket
  end

  def follower_songsockets
    return @members.map{|m| m.songsocket}
  end

  def all_songsockets
    return (@members + [@leader]).map{|m| m.songbook_socket}
  end

  def add_member(user)
    @members << user
  end

  def delete_member(user)
    @members.delete(user)
  end

  def close
    all_songsockets.each {|s| s.send_json({"session" => "end"}); s.close}
  end

  def forward_songs(song_list)
    follower_songsockets.each do |g|
      send_json({"session" => "start", "songs" => song_list}.to_json)
    end
  end

  def update_group_info
    msg = (@members + [@leader]).map{|m| m.name}.to_json
    all_songsockets.each {|s| s.send_json(msg)}
  end
end
