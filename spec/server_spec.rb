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

  # todo handle disconnection issues
  describe "on grouping" do

        before do
            @s_threads = Server.new.launch(true)
            @socket = TCPSocket.open("localhost", 44106)
            @socket.print ( {"request" =>"create group","group name" => "stp","user name" => "scott"}.to_json + "\n" ) 
            response =  JSON.parse(@socket.gets)
            expect(response["response"]).to eq("ok")
        end

        it "fails to create if group already exists" do
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response =  JSON.parse(socket2.gets)
            expect(response["response"]).to eq("error")
            socket2.close
        end

        it "fails to join if group does not exist" do
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.print ( {"request" =>"join group","group name" => "weezer","user name" => "martha"}.to_json + "\n" ) 
            response =  JSON.parse(socket2.gets)
            expect(response["response"]).to eq("error")
            socket2.close
        end

        it "successfully joins existing group" do
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.print ( {"request" =>"join group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response = JSON.parse(socket2.gets)
            expect(response["response"]).to eq("ok")
            socket2.close
        end

        after do
            @socket.close
            @s_threads.each { |s| s.close}
        end
    end


      # todo handle disconnection issues
    describe "on disconnections" do

        it "terminates group where leader left" do

            s_threads = Server.new.launch(true)

            # Have user create group
            socket = TCPSocket.open("localhost", 44106)
            socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response =  JSON.parse(socket.gets)

            # Have user connect to group
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.print ( {"request" =>"join group","group name" => "stp","user name" => "amy"}.to_json + "\n" ) 
            response =  JSON.parse(socket2.gets)

            # band leader disconnects
            puts "closed a socket."
            socket.close
            
            # Give server some time to process, close sockets.
            sleep(0.5)


            socket = TCPSocket.open("localhost", 44106)
            socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response =  JSON.parse(socket.gets)
            expect(response["response"]).to eq("ok")
            s_threads.each { |s| s.close}
        end

        it "cancels group members who leave" do

            s_threads = Server.new.launch(true)

            # Have user create group
            socket = TCPSocket.open("localhost", 44106)
            socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response =  JSON.parse(socket.gets)

            # Have user connect to group
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.print ( {"request" =>"join group","group name" => "stp","user name" => "amy"}.to_json + "\n" ) 
            response =  JSON.parse(socket2.gets)

            # band member disconnects
            puts "closed a socket."
            socket2.close
            
            # Give server some time to process, close sockets.
            sleep(0.2)
            socket.close
            s_threads.each { |s| s.close}
        end
    end

    describe "on instrument selection" do

        it "updates instruments" do
            sleep(1)

            s_threads = Server.new.launch(true)
            # Have user create group
            socket = TCPSocket.open("localhost", 44106)
            socket.print ( {"request" =>"create group","group name" => "stp","user name" => "martha"}.to_json + "\n" ) 
            response = JSON.parse(socket.gets)
            # (ok)

            # Have user connect to group
            socket2 = TCPSocket.open("localhost", 44107)
            socket2.puts ( {"request" =>"join group","group name" => "stp","user name" => "amy"}.to_json ) 

            # consume the user joined group message
            socket.gets
            # tell the server to make amy play guitar and sing
            socket.puts ({"request" => "set instrument","instruments" => ["guitar","vocal"],"user name" => "amy"}.to_json)
            response = JSON.parse(socket.gets)
            # first member (martha) is playing guitar
            expect(response[1]["instruments"][0]).to eq("guitar")
            socket.close
            socket2.close
            s_threads.each { |s| s.close}
        end
    end
end
