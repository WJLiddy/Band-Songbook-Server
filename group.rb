class Group
  attr_reader :members
  def initialize(leader)
    @leader = leader
    @members = []
  end
  
  def to_json
    (@members + [@leader]).map { |e| e.to_json }
  end
end
