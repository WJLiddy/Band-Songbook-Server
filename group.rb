class Group
	def initialize(leader)
		@leader = leader
		@members = []
	end

	def to_json
	  (@members + @leader).map {|e| e.to_json}
	end
end

