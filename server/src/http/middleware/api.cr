module DMACServer
  module HttpAPI
    class ApiHandler < Kemal::Handler
      def call(context)
        context.response.headers["Access-Control-Allow-Origin"] = "*"
        context.response.content_type = "application/json"
        context.response.headers["Access-Control-Allow-Headers"] = "Origin, X-Requested-With, Content-Type, Accept, X-Token, X-AppToken, Authorization"
        context.response.headers["Access-Control-Allow-Methods"] = "PUT, GET, POST, DELETE, OPTIONS"
        if context.request.method == "OPTIONS"
          context.response.status_code = 200
        else
          call_next(context)
        end
      end
    end
  end
end

