require_relative "../server"
describe Server do
  it "throws an error for invalid JSON" do
    Server.new.launch
    socket = TCPSocket.open(localhost, 44106)
    socket.print("{ i'm not a valid json")
    response = socket.read
    expect(response["error"]).to_be true
    expect(response['error message']).to_be 'malformed json'
  end
end
