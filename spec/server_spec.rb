require_relative "../server"


describe Server do
  it "throws an error for invalid JSON" do
    s_threads = Server.new.launch(true)
    socket = TCPSocket.open("localhost", 44106)
    socket.print("{ i'm not a valid json \n")
    response =  JSON.parse(socket.gets)
    expect(response["response"]).to eq("error")
    socket.close
    s_threads.each { |s| s.close}
  end

  it "allows group creation" do
    s_threads = Server.new.launch(true)
    socket = TCPSocket.open("localhost", 44106)
    socket.print ( {"request" =>"create group","group name" => "stp","user name" => "scott"}.to_json + "\n" ) 
    response =  JSON.parse(socket.gets)
    expect(response["response"]).to eq("ok")
    s_threads.each { |s| s.close}
  end
end
