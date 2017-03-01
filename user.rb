class User
  attr_reader :name, :socket
  def initialize(uname, socket)
    @name = uname
    @socket = socket
  end

  def jsonize
    {"name" => @name}
  end
end
