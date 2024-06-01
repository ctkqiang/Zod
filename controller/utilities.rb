require "socket"

class Utilities
    def initialize
    end

    def get_ip
        ip = Socket.ip_address_list.detect do |intf|
            intf.ipv4_private?
        end
        
        ip.ip_address if ip
    end
end