class ActionDispatch::Request
    alias_method :original_remote_ip, :remote_ip
    def remote_ip
        headers["CF_CONNECTING_IP"] || original_remote_ip
    end
end