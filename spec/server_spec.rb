require_relative "../server"
describe Server do
  it "throws an error for invalid JSON" do
    Server.new.launch(true)
    socket = TCPSocket.open("localhost", 44106)
    socket.print("{ i'm not a valid json\n")
    puts "awaiting response..."
    response = socket.read
    puts "done!"
    expect(response["error"]).to_be true
    expect(response['error message']).to_be 'malformed json'
  end
end
