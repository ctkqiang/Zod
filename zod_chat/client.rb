require 'websocket-client-simple'
require 'securerandom'

puts "Enter Host: "

ip_addr = gets.chomp
url = "ws://#{ip_addr}:8001"

uid = SecureRandom.hex(18)

client = WebSocket::Client::Simple.connect(url)

puts "|Zod Chat Room id: #{uid} |"

client.on :message do |msg|
  puts "|Zod|> #{msg.data}"
end

client.on :close do |e|
  puts "Connection closed: #{e}"
  exit
end

client.on :error do |e|
  puts "Error: #{e}"
end

puts "Connected to #{url}. Type 'exit' to quit."

loop do
  print "> "
  message = gets.chomp
  break if message.downcase == 'exit'
  client.send(message)
end
