require "em-websocket"
require "securerandom"

require_relative "..//controller/utilities.rb"

connections = {}
next_user_id = 1

EM.run do
    uid = SecureRandom.hex(18)
    current_ip = Utilities.new().get_ip

    puts "|Zod Chat Room id:#{SecureRandom.hex(15)} |"
    puts "|Zod|> hosted -> ws://#{current_ip}\n"
    
    EM::WebSocket.run(host: "0.0.0.0", port: 8001) do |ws|
        ws.onopen do |handshake|

        puts "|Zod|> #{uid} Joined Chat"
        
        # Notify other users about the new user
            connections.each do |id, connection|
                connection[:ws].send("#{uid} has joined the chat.")
            end
        end
        
        ws.onmessage do |msg|
            puts "|Zod|> #{uid}: #{msg}"
            
            if msg.start_with?("/")
                
            else
                connections.each do |id, connection|
                next if connection[:ws] == ws
                connection[:ws].send("#{username}: #{msg}")
                end
            end
        end

        ws.onclose do

            user_id = connections.key({ ws: ws })
            username = connections[user_id]&.fetch(:username, "Unknown User")
            
            connections.delete(user_id)
            
            # Notify other users about the disconnected user
            connections.each do |id, connection|
                connection[:ws].send("#{username} has left the chat.")
            end
        end
    end
end
