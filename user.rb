class User
	attr_reader :name, :instruments, :socket
	@instruments = []
	def initialize(name, socket)
		@name = name
		@socket = socket
	end

	def to_json
		{"name" => @name, "instruments" => @instruments}.to_json
	end
end