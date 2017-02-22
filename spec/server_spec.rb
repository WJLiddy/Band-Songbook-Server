require_relative "../server"
describe Server do
  it "throws an error for invalid JSON" do
    Server.new.launch(true)
    socket = TCPSocket.open("localhost", 44106)
    socket.print("{ i'm not a valid json \n")
    response =  JSON.parse(socket.read)
    expect(response["response"]).to eq("error")
    puts "got #{response}"
  end
end
