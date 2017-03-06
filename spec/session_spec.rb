#Setup phase. have two people connect before each test
describe Server do
  before(:example) do
    @thing = Thing.new
  end

  it "forwards songs to clients"
    s_threads = Server.new.launch(true)

    # Have user create group
    socket = TCPSocket.open("localhost", 44106)
    socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
    response =  JSON.parse(socket.gets)

    # Have user connect to group
    socket2 = TCPSocket.open("localhost", 44107)
    socket2.print ( {"request" =>"join group","group name" => "stp","user name" => "amy"}.to_json + "\n" ) 
    response =  JSON.parse(socket2.gets)

    # Have martha upload two songs.
    songs = [File.open("tabs/XML/Traditional - Silent Night.xml").read , File.open("tabs/XML/Green Day - When I Come Around v4.xml").read]
    socket.puts ({"request" => "begin session", "songs" => songs }).to_json

    puts JSON::parse(socket2.gets)["songs"][1]
end
