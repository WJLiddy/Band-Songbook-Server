require_relative "../server"
require 'socket'
require 'json'

#Setup phase. have two people connect before each test
describe Server do

  before(:all) do
    @s_threads = Server.new.launch(true)
  end

  after(:all) do
    @s_threads.each { |s| s.close}
  end

  before(:each) do

    # Have user create group
    @socket = TCPSocket.open("localhost", 44106)
    @socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
    response =  JSON.parse(@socket.gets)

    # Have user connect to group
    @socket2 = TCPSocket.open("localhost", 44107)
    @socket2.print ( {"request" =>"join group","group name" => "stp","user name" => "amy"}.to_json + "\n" ) 
    response =  JSON.parse(@socket2.gets)
    response =  JSON.parse(@socket2.gets)
  end

  it "forwards songs to clients" do
    # Have martha upload two songs.
    songs = [File.open("tabs/XML/Traditional - Silent Night.xml").read , File.open("tabs/XML/Green Day - When I Come Around v4.xml").read]
    @socket.puts ({"request" => "begin session", "songs" => songs }.to_json)

    msg = JSON::parse(@socket2.gets)
    expect(msg["session"]).to eq("start")
    # TODO. parse XML. But, this wrks
    expect(msg["songs"][0][0]).to eq("<")
  end

  it "allows clients to switch songs" do
    # Have martha upload two songs.
    songs = [File.open("tabs/XML/Traditional - Silent Night.xml").read , File.open("tabs/XML/Green Day - When I Come Around v4.xml").read]
    @socket.puts ({"request" => "begin session", "songs" => songs }.to_json)

    # The XML is parsed and the session is started.
    msg = JSON::parse(@socket2.gets)

    puts "switching song..."
    # Matha says to switch to the second song.
    @socket.print ( {"request" =>"switch song","song id" => 1}.to_json + "\n" ) 

    # Amy should recieve this exact message.
    msg = JSON::parse(@socket2.gets)
    puts "MSG IS #{msg}"
    puts "SONG ID IS #{msg["song id"]}"
    expect(msg["song id"]).to eq(1)
  end

    it "allows clients to start songs" do
    # Have martha upload two songs.
    songs = [File.open("tabs/XML/Traditional - Silent Night.xml").read , File.open("tabs/XML/Green Day - When I Come Around v4.xml").read]
    @socket.puts ({"request" => "begin session", "songs" => songs }.to_json)

    # The XML is parsed and the session is started.
    msg = JSON::parse(@socket2.gets)

    puts "start song..."
    # Matha says to switch to the second song.
    @socket.print ( {"request" =>"begin playback","measure" => 10, "tempo" => 0.7, "time" => 700}.to_json + "\n" ) 

    # Amy should recieve this exact message.
    msg = JSON::parse(@socket2.gets)
    puts "MSG IS #{msg}"
    expect(msg["session"]).to eq("begin playback")
    expect(msg["measure"]).to eq(10)
    expect(msg["tempo"]).to eq(0.7)
    expect(msg["time"]).to eq(700)
  end

  it "allows clients to end songs" do
    # Have martha upload two songs.
    songs = [File.open("tabs/XML/Traditional - Silent Night.xml").read , File.open("tabs/XML/Green Day - When I Come Around v4.xml").read]
    @socket.puts ({"request" => "begin session", "songs" => songs }.to_json)

    # The XML is parsed and the session is started.
    msg = JSON::parse(@socket2.gets)

    puts "stop song..."
    # Matha says to switch to the second song.
    @socket.print ( {"request" =>"stop playback"}.to_json + "\n" ) 

    # Amy should recieve this exact message.
    msg = JSON::parse(@socket2.gets)
    puts "MSG IS #{msg}"
    expect(msg["session"]).to eq("stop playback")
  end

  after(:each) do
    @socket.close
    @socket2.close
  end

end
