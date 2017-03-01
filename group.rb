# Just holds the names and sockets for all the users, and provides some group methods to address the entire group
class Group
  # define user struct
  User = Struct.new(:name, :songsocket)
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
    return (@members + @leader).map{|m| m.songsocket}
  end

  def add_member(user)
    @members << user
  end

  def delete_member(user)
    @members.delete(user)
  end

  def close_group
    @all_songsockets.send_json({"session" => "end"})
  end

  def forward_songs(song_list)
    follower_songsockets.each do |g|
      send_json({"session" => "start", "songs" => song_list}.to_json)
    end
  end

  def to_json
    @members.map{|m| m.jsonize}.to_json
  end
end
