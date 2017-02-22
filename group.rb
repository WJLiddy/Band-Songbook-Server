class Group
  attr_reader :members
  def initialize(leader)
    @members = [leader]
  end
  
  def to_json
    @members.map{|m| m.jsonize}.to_json
  end
end
