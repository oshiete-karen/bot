require 'webrick'
include WEBrick

class ServletAction < WEBrick::HTTPServlet::AbstractServlet
    def do_POST (req, res)
        res.body = '教えて'
    end
end
