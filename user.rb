class User
  attr_reader :name, :socket
  attr_accessor :instruments
  def initialize(name, socket)
    @name = name
    @socket = socket
    @instruments = []
  end

  def jsonize
    {"name" => @name, "instruments" => @instruments}
  end
end
