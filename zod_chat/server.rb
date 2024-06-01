require "em-websocket"
require "securerandom"

connections = {}
next_user_id = 1

EM.run do
    uid = SecureRandom.hex(18)
    
    EM::WebSocket.run(host: "0.0.0.0", port: 8080) do |ws|
        ws.onopen do |handshake|

        puts "|ZOD| New connection: #{uid}"
        
        # Notify other users about the new user
            connections.each do |id, connection|
                connection[:ws].send("#{uid} has joined the chat.")
            end
        end
        
        ws.onmessage do |msg|
            puts "|ZOD | Received message from #{uid}: #{msg}"
            
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
